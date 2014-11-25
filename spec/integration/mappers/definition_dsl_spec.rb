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

  describe 'default PORO mapper' do
    subject(:mapper) { rom.read(:users).mapper }

    before do
      setup.mappers do
        define(:users) do
          model name: 'User'
        end
      end
    end

    it 'defines a constant for the model class' do
      expect(mapper.model).to be(User)
    end

    it 'uses all attributes from the relation header by default' do
      expect(header.keys).to eql(rom.relations.users.header)
    end
  end

  describe 'excluding attributes' do
    subject(:mapper) { rom.read(:users).mapper }

    before do
      setup.mappers do
        define(:users) do
          model name: 'User'

          exclude :name
        end
      end
    end

    it 'only maps provided attributes' do
      expect(header.keys).to eql([:email])
    end
  end

  describe 'virtual relation mapper' do
    subject(:mapper) { rom.read(:users).email_index.mapper }

    before do
      setup.mappers do
        define(:users) do
          model name: 'User'
        end
      end

      setup.mappers do
        define(:email_index, parent: :users) do
          model name: 'UserWithoutName'
          exclude :name
        end
      end
    end

    it 'inherits the attributes from the parent by default' do
      expect(header.keys).to eql(rom.mappers[:users].header - [:name])
    end

    it 'builds a new model' do
      expect(mapper.model).to be(UserWithoutName)
    end

  end

  describe 'grouped relation mapper' do
    before do
      setup.relation(:tasks)

      setup.relation(:users) do
        def with_tasks
          in_memory { group(join(tasks), tasks: [:title, :priority]) }
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

  end

  describe 'wrapped relation mapper' do
    before do
      setup.relation(:tasks) do
        def with_user
          in_memory { wrap(join(users), user: [:email]) }
        end
      end

      setup.relation(:users)

      setup.mappers do
        define(:tasks) do
          model name: 'Task'

          attribute :title
          attribute :priority
        end
      end
    end

    it 'allows defining wrapped attributes via options hash' do
      setup.mappers do
        define(:with_user, parent: :tasks) do
          model name: 'TaskWithUser'

          attribute :title
          attribute :priority

          wrap user: [:email]
        end
      end

      rom = setup.finalize

      TaskWithUser.send(:include, Equalizer.new(:title, :priority, :user))

      jane = rom.read(:tasks).with_user.to_a.last

      expect(jane).to eql(
        TaskWithUser.new(
          title: 'be cool',
          priority: 2,
          user: { email: 'jane@doe.org' }
        )
      )
    end

    it 'allows defining wrapped attributes via options block' do
      setup.mappers do
        define(:with_user, parent: :tasks) do
          model name: 'TaskWithUser'

          attribute :title
          attribute :priority

          wrap :user do
            attribute :email
          end
        end
      end

      rom = setup.finalize

      TaskWithUser.send(:include, Equalizer.new(:title, :priority, :user))

      jane = rom.read(:tasks).with_user.to_a.last

      expect(jane).to eql(
        TaskWithUser.new(
          title: 'be cool',
          priority: 2,
          user: { email: 'jane@doe.org' }
        )
      )
    end

  end

end
