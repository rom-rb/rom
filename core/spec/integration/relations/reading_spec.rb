require 'spec_helper'

RSpec.describe 'Reading relations' do
  include_context 'container'
  include_context 'users and tasks'

  before do
    configuration.relation(:tasks)

    configuration.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end

      def with_task
        join(tasks)
      end

      def with_tasks
        join(tasks)
      end

      def sorted
        order(:name, :email)
      end
    end
  end


  it 'exposes a relation reader' do
    configuration.mappers do
      define(:users) do
        model name: 'Test::User'

        attribute :name
        attribute :email
      end
    end

    users = users_relation.sorted.by_name('Jane').as(:users)
    user = users.first

    expect(user).to be_an_instance_of(Test::User)
    expect(user.name).to eql 'Jane'
    expect(user.email).to eql 'jane@doe.org'
  end

  it 'maps grouped relations' do
    configuration.mappers do
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

    container

    Test::User.send(:include, Dry::Equalizer(:name, :email))
    Test::UserWithTasks.send(:include, Dry::Equalizer(:name, :email, :tasks))

    user = container.relation(:users).sorted.as(:users).first

    expect(user).to eql(
      Test::User.new(name: "Jane", email: "jane@doe.org")
    )

    user = container.relation(:users).with_tasks.sorted.as(:with_tasks).first

    expect(user).to eql(
      Test::UserWithTasks.new(
        name: "Jane",
        email: "jane@doe.org",
        tasks: [{ title: "be cool", priority: 2 }])
    )
  end

  it 'maps wrapped relations' do
    configuration.mappers do
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

    container

    Test::User.send(:include, Dry::Equalizer(:name, :email))
    Test::UserWithTask.send(:include, Dry::Equalizer(:name, :email, :task))

    user = container.relation(:users).sorted.with_task.as(:with_task).first

    expect(user).to eql(
      Test::UserWithTask.new(name: "Jane", email: "jane@doe.org",
                             task: { title: "be cool", priority: 2 })
    )
  end

  it 'maps hashes' do
    configuration.mappers do
      define(:users)
    end

    user = container.relation(:users).by_name("Jane").as(:users).first

    expect(user).to eql(name: "Jane", email: "jane@doe.org")
  end

  it 'allows cherry-picking of a mapper' do
    configuration.mappers do
      define(:users) do
        attribute :name
        attribute :email
      end

      define(:prefixer, parent: :users) do
        attribute :user_name, from: :name
        attribute :user_email, from: :email
      end
    end

    user = container.relation(:users).map_with(:prefixer).first

    expect(user).to eql(user_name: 'Joe', user_email: "joe@doe.org")
  end

  it 'allows passing a block to retrieve relations for mapping' do
    configuration.mappers do
      define(:users) do
        attribute :name
        attribute :email
      end

      define(:prefixer, parent: :users) do
        attribute :user_name, from: :name
        attribute :user_email, from: :email
      end
    end

    expect {
      container.relation(:users, &:not_here)
    }.to raise_error(NoMethodError, /not_here/)

    expect {
      container.relation(:users) { |users| users.by_name('Joe') }.as(:not_here)
    }.to raise_error(ROM::MapperMissingError, /not_here/)

    user = container.relation(:users) { |users|
      users.by_name('Joe')
    }.map_with(:prefixer).call.first

    expect(user).to eql(user_name: 'Joe', user_email: "joe@doe.org")
  end
end
