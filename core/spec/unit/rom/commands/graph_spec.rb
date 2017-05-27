require 'spec_helper'
require 'dry-struct'

RSpec.describe ROM::Commands::Graph do
  shared_examples_for 'a persisted graph' do
    it 'returns nested results' do
      expect(command.call).to match_array([
        # parent users
        [
          { name: 'Jane' }
        ],
        [
          [
            # user tasks
            [
              { title: 'One', user: 'Jane' }
            ],
            [
              # task tags
              [
                { name: 'red', task: 'One' },
                { name: 'green', task: 'One' },
                { name: 'blue', task: 'One' }
              ]
            ]
          ]
        ]
      ])
    end

    context 'persisted relations' do
      before { command.call }

      it 'inserts root' do
        expect(container.relation(:users)).to match_array([{ name: 'Jane' }])
      end

      it 'inserts root nodes' do
        expect(container.relation(:tasks)).to match_array([{ user: 'Jane', title: 'One' }])
      end

      it 'inserts nested graph nodes' do
        expect(container.relation(:tags)).to match_array([
          { name: 'red', task: 'One' },
          { name: 'green', task: 'One' },
          { name: 'blue', task: 'One' }
        ])
      end
    end
  end

  include_context 'container'

  let(:create_user) { container.command(:users).create }
  let(:create_task) { container.command(:tasks).create }

  let(:create_many_tasks) { container.command(:tasks).create_many }
  let(:create_many_tags) { container.command(:tags).create_many }

  let(:user) { { name: 'Jane' } }
  let(:task) { { title: 'One' } }
  let(:tags) { [{ name: 'red' }, { name: 'green' }, { name: 'blue' }] }

  before do
    configuration.relation(:users)
    configuration.relation(:tasks)
    configuration.relation(:tags)

    configuration.commands(:users) do
      define(:create) do
        result :one
      end
    end

    configuration.commands(:tasks) do
      define(:create) do
        result :one
        before :associate

        def associate(task, user)
          task.merge(user: user[:name])
        end
      end

      define(:create) do
        register_as :create_many
        before :associate

        def associate(tasks, user)
          tasks.map { |t| t.merge(user: user[:name]) }
        end
      end
    end

    configuration.commands(:tags) do
      define(:create) do
        register_as :create_many
        before :associate

        def associate(tags, tasks)
          Array([tasks]).flatten.map { |task|
            tags.map { |tag| tag.merge(task: task[:title]) }
          }.flatten
        end
      end
    end
  end

  describe '#call' do
    context 'when result is :one in root and its direct children' do
      it_behaves_like 'a persisted graph' do
        subject(:command) do
          create_user.with(user)
            .combine(create_task.with(task)
            .combine(create_many_tags.with(tags)))
        end
      end
    end

    context 'when result is :many for root direct children' do
      it_behaves_like 'a persisted graph' do
        subject(:command) do
          create_user.with(user)
            .combine(create_many_tasks.with([task])
            .combine(create_many_tags.with(tags)))
        end
      end
    end
  end

  describe 'pipeline' do
    subject(:command) do
      container.command(:users).as(:entity).create.with(user)
        .combine(create_task.with(task)
        .combine(create_many_tags.with(tags)))
    end

    before do
      Test::Tag = Class.new(Dry::Struct) {
        attribute :name, Types::String
      }

      Test::Task = Class.new(Dry::Struct) {
        attribute :title, Types::String
        attribute :tags, Types::Array.member(Test::Tag)
      }

      Test::User = Class.new(Dry::Struct) {
        attribute :name, Types::String
        attribute :task, Test::Task
      }

      class Test::UserMapper < ROM::Mapper
        relation :users
        register_as :entity
        reject_keys :true

        model Test::User

        attribute :name

        combine :task, on: { name: :user }, type: :hash do
          model Test::Task

          attribute :title

          combine :tags, on: { title: :task } do
            model Test::Tag
            attribute :name
          end
        end
      end
      configuration.register_mapper(Test::UserMapper)
    end

    it 'sends data through the pipeline' do
      expect(command.call).to eql(
        Test::User.new(
          name: 'Jane',
          task: Test::Task.new(
            title: 'One',
            tags: [
              Test::Tag.new(name: 'red'),
              Test::Tag.new(name: 'green'),
              Test::Tag.new(name: 'blue')
            ]
          )
        )
      )
    end
  end
end
