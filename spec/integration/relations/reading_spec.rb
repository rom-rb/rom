require 'spec_helper'

describe 'Reading relations' do
  include_context 'users and tasks'

  it 'exposes a relation reader' do
    setup.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end

      def sorted
        order(:name, :email)
      end
    end

    setup.mappers do
      define(:users) do
        model name: 'User'
      end
    end

    rom = setup.finalize

    users = rom.read(:users).sorted.by_name('Jane')
    user = users.first

    expect(user).to be_an_instance_of(User)
    expect(user.name).to eql 'Jane'
    expect(user.email).to eql 'jane@doe.org'
  end

  it 'maps grouped relations' do
    setup.relation(:users) do
      include ROM::RA

      def with_tasks
        join(tasks)
      end

      def sorted
        order(:name)
      end
    end

    setup.mappers do
      define(:users) do
        model name: 'User'
      end

      define(:with_tasks, parent: :users) do
        model name: 'UserWithTasks'

        group tasks: [:title, :priority]
      end
    end

    rom = setup.finalize

    User.send(:include, Equalizer.new(:name, :email))
    UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))

    expect(rom.read(:users).with_tasks.header.keys).to eql([:name, :email, :tasks])

    user = rom.read(:users).sorted.first

    expect(user).to eql(
      User.new(name: "Jane", email: "jane@doe.org")
    )

    user = rom.read(:users).with_tasks.sorted.first

    expect(user).to eql(
      UserWithTasks.new(
        name: "Jane",
        email: "jane@doe.org",
        tasks: [{ title: "be cool", priority: 2 }])
    )
  end

  it 'maps wrapped relations' do
    setup.relation(:users) do
      include ROM::RA

      def with_task
        join(tasks)
      end

      def sorted
        order(:name)
      end
    end

    setup.mappers do
      define(:users) do
        model name: 'User'
      end

      define(:with_task, parent: :users) do
        model name: 'UserWithTask'

        wrap task: [:title, :priority]
      end
    end

    rom = setup.finalize

    User.send(:include, Equalizer.new(:name, :email))
    UserWithTask.send(:include, Equalizer.new(:name, :email, :task))

    expect(rom.read(:users).with_task.header.keys).to eql([:name, :email, :task])

    user = rom.read(:users).sorted.with_task.first

    expect(user).to eql(
      UserWithTask.new(name: "Jane", email: "jane@doe.org",
                       task: { title: "be cool", priority: 2 })
    )
  end

  it 'maps hashes' do
    setup.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end
    end

    setup.mappers do
      define(:users)
    end

    rom = setup.finalize

    user = rom.read(:users).by_name("Jane").first

    expect(user).to eql(name: "Jane", email: "jane@doe.org")
  end
end
