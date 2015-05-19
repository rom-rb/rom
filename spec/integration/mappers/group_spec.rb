require 'spec_helper'

describe 'Mapper definition DSL' do
  include_context 'users and tasks'

  let(:header) { mapper.header }

  describe 'grouped relation mapper' do
    before do
      setup.relation(:tasks) do
        def with_users
          join(users)
        end
      end

      setup.relation(:users) do
        def with_tasks
          join(tasks)
        end
      end

      setup.mappers do
        define(:users) do
          model name: 'Test::User'

          attribute :name
          attribute :email
        end
      end
    end

    it 'allows defining grouped attributes via options hash' do
      setup.mappers do
        define(:with_tasks, parent: :users) do
          model name: 'Test::UserWithTasks'

          attribute :name
          attribute :email

          group tasks: [:title, :priority]
        end
      end

      rom = setup.finalize

      Test::UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))

      jane = rom.relation(:users).with_tasks.map_with(:with_tasks).to_a.last

      expect(jane).to eql(
        Test::UserWithTasks.new(
          name: 'Jane',
          email: 'jane@doe.org',
          tasks: [{ title: 'be cool', priority: 2 }]
        )
      )
    end

    it 'allows defining grouped attributes via block' do
      setup.mappers do
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

      rom = setup.finalize

      Test::UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))

      jane = rom.relation(:users).with_tasks.map_with(:with_tasks).to_a.last

      expect(jane).to eql(
        Test::UserWithTasks.new(
          name: 'Jane',
          email: 'jane@doe.org',
          tasks: [{ title: 'be cool', priority: 2 }]
        )
      )
    end

    it 'allows defining grouped attributes mapped to a model via block' do
      setup.mappers do
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

      rom = setup.finalize

      Test::UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))
      Test::Task.send(:include, Equalizer.new(:title, :priority))

      jane = rom.relation(:users).with_tasks.map_with(:with_tasks).to_a.last

      expect(jane).to eql(
        Test::UserWithTasks.new(
          name: 'Jane',
          email: 'jane@doe.org',
          tasks: [Test::Task.new(title: 'be cool', priority: 2)]
        )
      )
    end

    it 'allows defining nested grouped attributes mapped to a model via block' do
      setup.mappers do
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

      rom = setup.finalize

      Test::TaskWithUsers.send(:include, Equalizer.new(:title, :priority, :users))
      Test::TaskUser.send(:include, Equalizer.new(:name, :contacts))
      Test::Contact.send(:include, Equalizer.new(:email))

      task = rom.relation(:tasks).with_users.map_with(:with_users).first

      expect(task).to eql(
        Test::TaskWithUsers.new(title: 'be nice', priority: 1, users: [
          Test::TaskUser.new(name: 'Joe', contacts: [
            Test::Contact.new(email: 'joe@doe.org')
          ])
        ])
      )
    end

    it 'allows defining grouped attributes with the same name as their keys' do
      setup.mappers do
        define(:with_tasks, parent: :users) do

          attribute :name
          attribute :email

          group title: [:title, :priority]
        end
      end

      rom = setup.finalize

      jane = rom.relation(:users).with_tasks.map_with(:with_tasks).to_a.last

      expect(jane).to eql(
        name: 'Jane',
        email: 'jane@doe.org',
        title: [{ title: 'be cool', priority: 2 }]
      )
    end
  end
end
