require 'spec_helper'

describe ROM::Commands::Graph do
  shared_examples_for 'a persisted graph' do
    it 'returns nested results' do
      expect(command.call).to match_array([
        # parent users
        [
          { name: 'Jane' },
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
        expect(rom.relation(:users)).to match_array([{ name: 'Jane' }])
      end

      it 'inserts root nodes' do
        expect(rom.relation(:tasks)).to match_array([{ user: 'Jane', title: 'One' }])
      end

      it 'inserts nested graph nodes' do
        expect(rom.relation(:tags)).to match_array([
          { name: 'red', task: 'One' },
          { name: 'green', task: 'One' },
          { name: 'blue', task: 'One' }
        ])
      end
    end
  end

  let(:rom) { setup.finalize }
  let(:setup) { ROM.setup(:memory) }

  let(:create_user) { rom.command(:users).create }
  let(:create_task) { rom.command(:tasks).create }
  let(:create_tags) { rom.command(:tags).create }

  let(:create_many_users) { rom.command(:users).create_many }
  let(:create_many_tasks) { rom.command(:tasks).create_many }
  let(:create_tags) { rom.command(:tags).create }

  let(:user) { { name: 'Jane' } }
  let(:task) { { title: 'One' } }
  let(:tags) { [{ name: 'red' }, { name: 'green' }, { name: 'blue' }] }

  before do
    setup.relation(:users)
    setup.relation(:tasks)
    setup.relation(:tags)

    setup.commands(:users) do
      define(:create) do
        result :one
      end

      define(:create) do
        register_as :create_many
      end
    end

    setup.commands(:tasks) do
      define(:create) do
        result :one

        def execute(task, user)
          super(task.merge(user: user[:name]))
        end
      end

      define(:create) do
        register_as :create_many

        def execute(tasks, user)
          super(tasks.map { |t| t.merge(user: user[:name]) })
        end
      end
    end

    setup.commands(:tags) do
      define(:create) do
        def execute(tags, task)
          super(tags.map { |t| t.merge(task: task[:title]) })
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
            .combine(create_tags.with(tags)))
        end
      end
    end

    context 'when result is :many in root and its direct children' do
      it_behaves_like 'a persisted graph' do
        subject(:command) do
          create_many_users.with([user])
            .combine(create_many_tasks.with([task])
            .combine(create_tags.with(tags)))
        end
      end
    end
  end

  describe 'pipeline' do
    subject(:command) do
      rom.command(:users).as(:entity).create.with(user)
        .combine(create_task.with(task)
        .combine(create_tags.with(tags)))
    end

    before do
      Test::Tag = Class.new { include Anima.new(:name) }
      Test::Task = Class.new { include Anima.new(:title, :tags) }
      Test::User = Class.new { include Anima.new(:name, :task) }

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
              Test::Tag.new(name: 'blue'),
            ]
          )
        )
      )
    end
  end
end
