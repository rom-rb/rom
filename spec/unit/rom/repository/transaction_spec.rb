# frozen_string_literal: true

require "rom-repository"
require "rom-changeset"

RSpec.describe ROM::Repository, "#transaction" do
  let(:user_repo) do
    Class.new(ROM::Repository[:users]) { commands :create, update: :by_pk }.new(rom)
  end

  let(:task_repo) do
    Class.new(ROM::Repository[:tasks]) { commands :create, :update }.new(rom)
  end

  include_context "repository / database"
  include_context "relations"

  it "creating user with tasks" do
    user, task = user_repo.transaction do
      user_changeset = user_repo.users.changeset(:create, name: "Jane")
      task_changeset = user_repo.tasks.changeset(:create, title: "Task One")

      user = user_repo.create(user_changeset)
      task = task_repo.create(task_changeset.associate(user, :user))

      [user, task]
    end

    expect(user.name).to eql("Jane")
    expect(task.user_id).to be(user.id)
    expect(task.title).to eql("Task One")
  end

  it "updating tasks user" do
    jane = user_repo.create(name: "Jane")
    john = user_repo.create(name: "John")
    task = task_repo.create(title: "Jane Task", user_id: jane.id)

    task = task_repo.transaction do
      task_changeset = tasks.by_pk(task.id)
        .changeset(:update, title: "John Task")
        .associate(john, :user)
        .commit

      task_repo.update(task_changeset)
    end

    expect(task.user_id).to be(john.id)
    expect(task.title).to eql("John Task")
  end

  it "allows for transaction options" do
    user = user_repo.create(name: "John")

    user_repo.transaction do
      user_repo.update(user.id, name: "Jane")
      user_repo.transaction(savepoint: true) { raise Sequel::Rollback }
    end

    expect(users.by_pk(user.id).one).to include(name: "Jane")
  end

  context "options: gateway" do
    let(:configuration) do
      ROM::Configuration.new(
        default: [:sql, db_uri],
        alt: [:sql, db_uri],
      )
    end

    let(:alt_conn) do
      configuration.gateways[:alt].connection
    end

    before do
      alt_conn.drop_table?(:customers)

      alt_conn.create_table(:customers) do
        primary_key :id
        column :full_name, String
        column :user_id, Integer
      end

      joe_id = conn[:users].insert name: "Joe"

      alt_conn[:customers].insert(full_name: "Joe Black", user_id: joe_id)

      configuration.relation(:customers) do
        gateway :alt

        schema(infer: true) do
          associations do
            has_one :user
          end
        end
      end
    end

    let(:customer_repo) do
      Class.new(ROM::Repository[:customers]) { commands :create, update: :by_pk }.new(rom)
    end

    example "running transaction blocks with two connections" do
      customer_repo.transaction(gateway: :default) do |outer|
        user = user_repo.create(name: "Jane")

        customer_repo.transaction(savepoint: true) do |inner|
          customer_repo.create(full_name: "Jane", user_id: user.id)

          inner.rollback!
        end

        customer = customer_repo.root.where(user_id: user.id).one

        expect(customer).to be_nil

        outer.rollback!
      end

      user = user_repo.root.where(name: "Jane").one

      expect(user).to be_nil
    end
  end
end
