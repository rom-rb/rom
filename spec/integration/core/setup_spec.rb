# frozen_string_literal: true

require "dry/struct"

RSpec.describe "Configuring ROM" do
  context "with existing schema" do
    include_context "container"
    include_context "users and tasks"

    let(:jane) { {name: "Jane", email: "jane@doe.org"} }
    let(:joe) { {name: "Joe", email: "joe@doe.org"} }

    before do
      configuration.relation(:users)
      configuration.relation(:tasks)
    end

    it "configures schema relations" do
      expect(container.gateways[:default][:users]).to match_array([joe, jane])
    end

    it "configures rom relations" do
      users = container.relations.users

      expect(users).to be_kind_of(ROM::Relation)
      expect(users).to respond_to(:tasks)

      tasks = users.tasks

      expect(tasks).to be_kind_of(ROM::Relation)
      expect(tasks).to respond_to(:users)
      expect(tasks.users).to eql(users)
      expect(tasks.users.commands.namespace).to eql("commands.users")
    end

    it "configures rom schema to store relations" do
      users_schema = users_relation.schema
      tasks_schema = tasks_relation.schema

      expect(users_schema.relations[:users]).to eql(users_relation)
      expect(tasks_schema.relations[:tasks]).to eql(tasks_relation)
    end
  end

  context "without schema" do
    it "builds empty registries if there is no schema" do
      container = ROM.container(:memory)
      expect(container.relations).to be_empty
      expect(container.mappers).to be_empty
    end
  end

  describe "defining classes" do
    let(:container) do
      ROM.container(:memory) do |config|
        class Test::UserRelation < ROM::Relation[:memory]
          schema(:users) do
            attribute :name, ROM::Types::String
          end

          def by_name(name)
            restrict(name: name)
          end
        end

        class Test::TaskRelation < ROM::Relation[:memory]
          schema(:tasks) do
            attribute :title, ROM::Types::String
          end
        end

        class Test::CreateUser < ROM::Commands::Update[:memory]
          relation :users
          register_as :create
        end

        config.register_relation(Test::UserRelation, Test::TaskRelation)
        config.register_command(Test::CreateUser)
      end
    end

    it "sets up registries based on class definitions" do
      expect(container.relations.users).to be_kind_of(Test::UserRelation)
      expect(container.relations.users.tasks).to eql(container.relations.tasks)

      expect(container.commands.users[:create]).to be_kind_of(Test::CreateUser)

      expect(container.relations.tasks).to be_kind_of(Test::TaskRelation)
      expect(container.relations.tasks.users).to eql(container.relations.users)
    end
  end

  describe "broken relation class" do
    before do
      class Test::BrokenRelation < ROM::Relation
        schema(:users) {}
      end
    end

    it "raises when a class is missing adapter identifier" do
      pending "TODO: restore relation setting validation"

      expect {
        ROM.container(:memory) { |config| config.register_relation(Test::BrokenRelation) }
          .relations.users
      }.to raise_error(ROM::MissingAdapterIdentifierError, /Test::BrokenRelation/)
    end
  end

  describe "quick setup" do
    # NOTE: move to DSL tests
    it "exposes boot DSL inside the setup block via `macros` plugin" do
      module Test
        User = Class.new(Dry::Struct) do
          attribute :name, Types::String
        end
      end

      container = ROM.container(:memory) do |rom|
        rom.relation(:users) do
          def by_name(name)
            restrict(name: name)
          end
        end

        rom.commands(:users) do
          define(:create)
        end

        rom.mappers do
          define(:users) do
            model Test::User
          end
        end
      end

      container.commands.users.create.call(name: "Jane")

      expect(container.relations[:users].by_name("Jane").map_with(:users).to_a)
        .to eql([Test::User.new(name: "Jane")])

      expect(container.relations[:users].mappers.compiler).to be_instance_of(ROM::Memory::MapperCompiler)
    end
  end

  describe "multi-step setup" do
    it "exposes boot DSL that can be invoked multiple times" do
      module Test
        User = Class.new(Dry::Struct) do
          attribute :name, Types::String
        end
      end

      configuration = ROM::Configuration.new(:memory)

      configuration.relation(:users) do
        def by_name(name)
          restrict(name: name)
        end
      end

      configuration.commands(:users) do
        define(:create)
      end

      configuration.mappers do
        define(:users) do
          model Test::User
        end
      end

      container = ROM.container(configuration)

      container.commands[:users].create.call(name: "Jane")

      expect(container.relations[:users].by_name("Jane").map_with(:users).to_a)
        .to eql([Test::User.new(name: "Jane")])
    end
  end

  it "allows to use a relation with a schema in multiple containers" do
    class Test::UserRelation < ROM::Relation[:memory]
      schema(:users) do
        attribute :id, Types::Integer.meta(primary_key: true)
      end
    end

    2.times do
      ROM.container(:memory) { |c| c.register_relation(Test::UserRelation) }
    end
  end

  describe "configuring plugins for all relations" do
    it "allows setting instrumentation for relations" do
      Test::Notifications = double(:notifications)

      configuration = ROM::Configuration.new(:memory)

      configuration.plugin(:memory, relations: :instrumentation) do |p|
        p.notifications = Test::Notifications
      end

      configuration.relation(:users)

      container = ROM.container(configuration)

      users = container.relations[:users]

      expect(users.notifications).to be(Test::Notifications)
    end
  end
end
