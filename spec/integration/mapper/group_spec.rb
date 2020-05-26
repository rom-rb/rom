# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Mapper definition DSL' do
  include_context 'container'
  include_context 'users and tasks'

  let(:header) { mapper.header }

  describe 'grouped relation mapper' do
    before do
      configuration.relation(:tasks) do
        def with_users
          join(users)
        end
      end

      configuration.relation(:users) do
        def with_tasks
          join(tasks)
        end
      end

      configuration.mappers do
        define(:users) do
          model name: 'Test::User'

          attribute :name
          attribute :email
        end
      end
    end

    it 'allows defining grouped attributes via options hash' do
      configuration.mappers do
        define(:with_tasks, parent: :users) do
          model name: 'Test::UserWithTasks'

          attribute :name
          attribute :email

          group tasks: %i[title priority]
        end
      end

      container

      Test::UserWithTasks.send(:include, Dry::Equalizer(:name, :email, :tasks))

      jane = container.relations[:users].with_tasks.map_with(:with_tasks).to_a.last

      expect(jane).to eql(
        Test::UserWithTasks.new(
          name: 'Jane',
          email: 'jane@doe.org',
          tasks: [{ title: 'be cool', priority: 2 }]
        )
      )
    end

    it 'allows defining grouped attributes via block' do
      configuration.mappers do
        define(:with_tasks, parent: :users) do
          model name: 'Test::UserWithTasks'

          attribute :name
          attribute :email

          group :tasks do
            attribute :title
            attribute :priority
          end
        end
      end

      container

      Test::UserWithTasks.send(:include, Dry::Equalizer(:name, :email, :tasks))

      jane = container.relations[:users].with_tasks.map_with(:with_tasks).to_a.last

      expect(jane).to eql(
        Test::UserWithTasks.new(
          name: 'Jane',
          email: 'jane@doe.org',
          tasks: [{ title: 'be cool', priority: 2 }]
        )
      )
    end

    it 'allows defining grouped attributes mapped to a model via block' do
      configuration.mappers do
        define(:with_tasks, parent: :users) do
          model name: 'Test::UserWithTasks'

          attribute :name
          attribute :email

          group :tasks do
            model name: 'Test::Task'

            attribute :title
            attribute :priority
          end
        end
      end

      container

      Test::UserWithTasks.send(:include, Dry::Equalizer(:name, :email, :tasks))
      Test::Task.send(:include, Dry::Equalizer(:title, :priority))

      jane = container.relations[:users].with_tasks.map_with(:with_tasks).to_a.last

      expect(jane).to eql(
        Test::UserWithTasks.new(
          name: 'Jane',
          email: 'jane@doe.org',
          tasks: [Test::Task.new(title: 'be cool', priority: 2)]
        )
      )
    end

    it 'allows defining nested grouped attributes mapped to a model via block' do
      configuration.mappers do
        define(:tasks)

        define(:with_users, parent: :tasks, inherit_header: false) do
          model name: 'Test::TaskWithUsers'

          attribute :title
          attribute :priority

          group :users do
            model name: 'Test::TaskUser'

            attribute :name

            group :contacts do
              model name: 'Test::Contact'
              attribute :email
            end
          end
        end
      end

      container

      Test::TaskWithUsers.send(:include, Dry::Equalizer(:title, :priority, :users))
      Test::TaskUser.send(:include, Dry::Equalizer(:name, :contacts))
      Test::Contact.send(:include, Dry::Equalizer(:email))

      task = container.relations[:tasks].with_users.map_with(:with_users).first

      expect(task).to eql(
        Test::TaskWithUsers.new(title: 'be nice', priority: 1, users: [
          Test::TaskUser.new(name: 'Joe', contacts: [
            Test::Contact.new(email: 'joe@doe.org')
          ])
        ])
      )
    end
  end
end
