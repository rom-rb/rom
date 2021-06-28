# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Reading relations" do
  include_context "container"
  include_context "users and tasks"

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

  it "exposes a relation reader" do
    configuration.mappers do
      define(:users) do
        model name: "Test::User"

        attribute :name
        attribute :email
      end
    end

    users = users_relation.sorted.by_name("Jane").map_with(:users)
    user = users.first

    expect(user).to be_an_instance_of(Test::User)
    expect(user.name).to eql "Jane"
    expect(user.email).to eql "jane@doe.org"
  end

  it "maps grouped relations" do
    configuration.mappers do
      define(:users) do
        model name: "Test::User"

        attribute :name
        attribute :email
      end

      define(:with_tasks, parent: :users) do
        model name: "Test::UserWithTasks"

        group tasks: %i[title priority]
      end
    end

    container.mappers[:users][:users]
    container.mappers[:users][:with_tasks]

    Test::User.send(:include, Dry::Equalizer(:name, :email))
    Test::UserWithTasks.send(:include, Dry::Equalizer(:name, :email, :tasks))

    user = container.relations[:users].sorted.map_with(:users).first

    expect(user).to eql(
      Test::User.new(name: "Jane", email: "jane@doe.org")
    )

    user = container.relations[:users].with_tasks.sorted.map_with(:with_tasks).first

    expect(user).to eql(
      Test::UserWithTasks.new(
        name: "Jane",
        email: "jane@doe.org",
        tasks: [{title: "be cool", priority: 2}]
      )
    )
  end

  it "maps wrapped relations" do
    configuration.mappers do
      define(:users) do
        model name: "Test::User"

        attribute :name
        attribute :email
      end

      define(:with_task, parent: :users) do
        model name: "Test::UserWithTask"

        wrap task: %i[title priority]
      end
    end

    container.mappers[:users][:users]
    container.mappers[:users][:with_task]

    Test::User.send(:include, Dry::Equalizer(:name, :email))
    Test::UserWithTask.send(:include, Dry::Equalizer(:name, :email, :task))

    user = container.relations[:users].sorted.with_task.map_with(:with_task).first

    expect(user).to eql(
      Test::UserWithTask.new(name: "Jane", email: "jane@doe.org",
                             task: {title: "be cool", priority: 2})
    )
  end

  it "maps hashes" do
    configuration.mappers do
      define(:users)
    end

    user = container.relations[:users].by_name("Jane").map_with(:users).first

    expect(user).to eql(name: "Jane", email: "jane@doe.org")
  end

  it "allows cherry-picking of a mapper" do
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

    user = container.relations[:users].map_with(:prefixer).first

    expect(user).to eql(user_name: "Joe", user_email: "joe@doe.org")
  end
end
