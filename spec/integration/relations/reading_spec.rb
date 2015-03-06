require 'spec_helper'

describe 'Reading relations' do
  include_context 'users and tasks'

  it 'exposes a relation reader' do
    setup.relation(:tasks)

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
        model name: 'Test::User'

        attribute :name
        attribute :email
      end
    end

    rom = setup.finalize

    users = rom.relation(:users).sorted.by_name('Jane').as(:users)
    user = users.first

    expect(user).to be_an_instance_of(Test::User)
    expect(user.name).to eql 'Jane'
    expect(user.email).to eql 'jane@doe.org'
  end

  it 'maps grouped relations' do
    setup.relation(:tasks)

    setup.relation(:users) do
      def with_tasks
        join(tasks)
      end

      def sorted
        order(:name)
      end
    end

    setup.mappers do
      define(:users) do
        model name: 'Test::User'

        attribute :name
        attribute :email
      end

      define(:with_tasks, parent: :users) do
        model name: 'Test::UserWithTasks'

        group tasks: [:title, :priority]
      end
    end

    rom = setup.finalize

    Test::User.send(:include, Equalizer.new(:name, :email))
    Test::UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))

    user = rom.relation(:users).sorted.as(:users).first

    expect(user).to eql(
      Test::User.new(name: "Jane", email: "jane@doe.org")
    )

    user = rom.relation(:users).with_tasks.sorted.as(:with_tasks).first

    expect(user).to eql(
      Test::UserWithTasks.new(
        name: "Jane",
        email: "jane@doe.org",
        tasks: [{ title: "be cool", priority: 2 }])
    )
  end

  it 'maps wrapped relations' do
    setup.relation(:tasks)

    setup.relation(:users) do
      def with_task
        join(tasks)
      end

      def sorted
        order(:name)
      end
    end

    setup.mappers do
      define(:users) do
        model name: 'Test::User'

        attribute :name
        attribute :email
      end

      define(:with_task, parent: :users) do
        model name: 'Test::UserWithTask'

        wrap task: [:title, :priority]
      end
    end

    rom = setup.finalize

    Test::User.send(:include, Equalizer.new(:name, :email))
    Test::UserWithTask.send(:include, Equalizer.new(:name, :email, :task))

    user = rom.relation(:users).sorted.with_task.as(:with_task).first

    expect(user).to eql(
      Test::UserWithTask.new(name: "Jane", email: "jane@doe.org",
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

    user = rom.relation(:users).by_name("Jane").as(:users).first

    expect(user).to eql(name: "Jane", email: "jane@doe.org")
  end

  it 'allows cherry-picking of a mapper' do
    setup.relation(:users)

    setup.mappers do
      define(:users) do
        attribute :name
        attribute :email
      end

      define(:prefixer, parent: :users) do
        attribute :user_name, from: :name
        attribute :user_email, from: :email
      end
    end

    rom = setup.finalize
    user = rom.relation(:users).map_with(:prefixer).first

    expect(user).to eql(user_name: 'Joe', user_email: "joe@doe.org")
  end

  it 'allows passing a block to retrieve relations for mapping' do
    setup.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end
    end

    setup.mappers do
      define(:users) do
        attribute :name
        attribute :email
      end

      define(:prefixer, parent: :users) do
        attribute :user_name, from: :name
        attribute :user_email, from: :email
      end
    end

    rom = setup.finalize

    expect {
      rom.relation(:users) { |users| users.not_here }
    }.to raise_error(NoMethodError, /not_here/)

    expect {
      rom.relation(:users) { |users| users.by_name('Joe') }.as(:not_here)
    }.to raise_error(ROM::MapperMissingError, /not_here/)

    user = rom.relation(:users) { |users|
      users.by_name('Joe')
    }.map_with(:prefixer).call.first

    expect(user).to eql(user_name: 'Joe', user_email: "joe@doe.org")
  end
end
