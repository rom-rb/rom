require 'spec_helper'

describe 'Mapper definition DSL' do
  include_context 'users and tasks'

  let(:header) { mapper.header }

  before do
    setup.relation(:users) do
      def email_index
        project(:email)
      end
    end
  end

  describe 'grouped relation mapper' do
    before do
      setup.relation(:tasks)

      setup.relation(:users) do
        include ROM::RA

        def with_tasks
          join(tasks)
        end
      end

      setup.mappers do
        define(:users) do
          model name: 'User'

          attribute :name
          attribute :email
        end
      end
    end

    it 'allows defining grouped attributes via options hash' do
      setup.mappers do
        define(:with_tasks, parent: :users) do
          model name: 'UserWithTasks'

          attribute :name
          attribute :email

          group tasks: [:title, :priority]
        end
      end

      rom = setup.finalize

      UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))

      jane = rom.read(:users).with_tasks.to_a.last

      expect(jane).to eql(
        UserWithTasks.new(
          name: 'Jane',
          email: 'jane@doe.org',
          tasks: [{ title: 'be cool', priority: 2 }]
        )
      )
    end

    it 'allows defining grouped attributes via block' do
      setup.mappers do
        define(:with_tasks, parent: :users) do
          model name: 'UserWithTasks'

          attribute :name
          attribute :email

          group :tasks do
            attribute :title
            attribute :priority
          end
        end
      end

      rom = setup.finalize

      UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))

      jane = rom.read(:users).with_tasks.to_a.last

      expect(jane).to eql(
        UserWithTasks.new(
          name: 'Jane',
          email: 'jane@doe.org',
          tasks: [{ title: 'be cool', priority: 2 }]
        )
      )
    end

    it 'allows defining grouped attributes mapped to a model via block' do
      setup.mappers do
        define(:with_tasks, parent: :users) do
          model name: 'UserWithTasks'

          attribute :name
          attribute :email

          group :tasks do
            model name: 'Task'

            attribute :title
            attribute :priority
          end
        end
      end

      rom = setup.finalize

      UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))
      Task.send(:include, Equalizer.new(:title, :priority))

      jane = rom.read(:users).with_tasks.to_a.last

      expect(jane).to eql(
        UserWithTasks.new(
          name: 'Jane',
          email: 'jane@doe.org',
          tasks: [Task.new(title: 'be cool', priority: 2)]
        )
      )
    end
  end
end
