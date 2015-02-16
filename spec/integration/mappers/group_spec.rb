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
          model name: 'ROMSpec::User'

          attribute :name
          attribute :email
        end
      end
    end

    it 'allows defining grouped attributes via options hash' do
      setup.mappers do
        define(:with_tasks, parent: :users) do
          model name: 'ROMSpec::UserWithTasks'

          attribute :name
          attribute :email

          group tasks: [:title, :priority]
        end
      end

      rom = setup.finalize

      ROMSpec::UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))

      jane = rom.read(:users).with_tasks.to_a.last

      expect(jane).to eql(
        ROMSpec::UserWithTasks.new(
          name: 'Jane',
          email: 'jane@doe.org',
          tasks: [{ title: 'be cool', priority: 2 }]
        )
      )
    end

    it 'allows defining grouped attributes via block' do
      setup.mappers do
        define(:with_tasks, parent: :users) do
          model name: 'ROMSpec::UserWithTasks'

          attribute :name
          attribute :email

          group :tasks do
            attribute :title
            attribute :priority
          end
        end
      end

      rom = setup.finalize

      ROMSpec::UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))

      jane = rom.read(:users).with_tasks.to_a.last

      expect(jane).to eql(
        ROMSpec::UserWithTasks.new(
          name: 'Jane',
          email: 'jane@doe.org',
          tasks: [{ title: 'be cool', priority: 2 }]
        )
      )
    end

    it 'allows defining grouped attributes mapped to a model via block' do
      setup.mappers do
        define(:with_tasks, parent: :users) do
          model name: 'ROMSpec::UserWithTasks'

          attribute :name
          attribute :email

          group :tasks do
            model name: 'ROMSpec::Task'

            attribute :title
            attribute :priority
          end
        end
      end

      rom = setup.finalize

      ROMSpec::UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))
      ROMSpec::Task.send(:include, Equalizer.new(:title, :priority))

      jane = rom.read(:users).with_tasks.to_a.last

      expect(jane).to eql(
        ROMSpec::UserWithTasks.new(
          name: 'Jane',
          email: 'jane@doe.org',
          tasks: [ROMSpec::Task.new(title: 'be cool', priority: 2)]
        )
      )
    end

    it 'allows defining nested grouped attributes mapped to a model via block' do
      setup.mappers do
        define(:tasks)

        define(:with_users, parent: :tasks, inherit_header: false) do
          model name: 'ROMSpec::TaskWithUsers'

          attribute :title
          attribute :priority

          group :users do
            model name: 'ROMSpec::TaskUser'

            attribute :name

            group :contacts do
              model name: 'ROMSpec::Contact'
              attribute :email
            end
          end
        end
      end

      rom = setup.finalize

      ROMSpec::TaskWithUsers.send(:include, Equalizer.new(:title, :priority, :users))
      ROMSpec::TaskUser.send(:include, Equalizer.new(:name, :contacts))
      ROMSpec::Contact.send(:include, Equalizer.new(:email))

      task = rom.read(:tasks).with_users.to_a.first

      expect(task).to eql(
        ROMSpec::TaskWithUsers.new(title: 'be nice', priority: 1, users: [
          ROMSpec::TaskUser.new(name: 'Joe', contacts: [
            ROMSpec::Contact.new(email: 'joe@doe.org')
          ])
        ])
      )
    end
  end
end
