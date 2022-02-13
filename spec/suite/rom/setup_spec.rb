# frozen_string_literal: true

require "rom/setup"

RSpec.describe ROM::Setup do
  subject(:setup) do
    ROM::Setup.new { |setup|
      setup.config.component.adapter = :memory
    }
  end

  let(:registry) do
    setup.registry
  end

  it "can define a dataset" do
    dataset = setup.dataset(:users) { [1, 2] }

    expect(dataset.config[:id]).to be(:users)
    expect(dataset.config[:gateway]).to be(:default)

    expect(registry["datasets.users"]).to eql([1, 2])
  end

  it "can define a dataset with a gateway" do
    setup.gateway(:default)
    setup.dataset(:users)

    expect(registry["datasets.users"]).to be_a(ROM::Memory::Dataset)
  end

  it "can define a schema" do
    schema = setup.schema(:users)

    expect(schema.config.id).to be(:users)
    expect(schema.config.gateway).to be(:default)

    expect(registry["schemas.users"]).to be_a(ROM::Schema)
  end

  it "can define a relation" do
    setup.gateway(:default)
    setup.dataset(:users)

    relation = setup.relation(:users)

    expect(relation.config.id).to be(:users)
    expect(relation.config.dataset).to be(:users)
    expect(relation.config.gateway).to be(:default)

    users = registry["relations.users"]

    expect(users).to be_a(ROM::Memory::Relation)
    expect(users.dataset).to be_a(ROM::Memory::Dataset)
  end

  it "can define a relation with a schema" do
    setup.gateway(:default)

    relation = setup.relation(:users) do
      schema { attribute(:id, ROM::Types::Integer) }
    end

    expect(relation.config.id).to be(:users)
    expect(relation.config.dataset).to be(:users)
    expect(relation.config.gateway).to be(:default)

    users = registry["relations.users"]

    expect(users).to be_a(ROM::Memory::Relation)
    expect(users.schema).to be_a(ROM::Schema)
    expect(users.schema[:id]).to be_a(ROM::Attribute)
  end

  it "can define a relation with a schema with its own dataset id" do
    setup.gateway(:default)

    relation = setup.relation(:people) do
      schema(dataset: :users) { attribute(:id, ROM::Types::Integer) }
    end

    expect(relation.config.id).to be(:people)
    expect(relation.config.gateway).to be(:default)

    users = registry["relations.people"]
    schema = registry["schemas.people"]

    expect(users).to be_a(ROM::Memory::Relation)
    expect(users.name.dataset).to be(:users)

    expect(users.schema).to be(schema)
    expect(users.schema).to be_a(ROM::Schema)
    expect(users.schema[:id]).to be_a(ROM::Attribute)
  end

  it "can define a relation with a schema and a dataset" do
    setup.gateway(:default)

    relation = setup.relation(:people) do
      schema do
        attribute(:uuid, ROM::Types::String)
        attribute(:name, ROM::Types::String)
      end

      dataset do |schema|
        insert(schema.map(&:name).map { |name| {name => "#{name}-value"} }.reduce(:merge))
      end
    end

    expect(relation.config.id).to be(:people)
    expect(relation.config.gateway).to be(:default)

    users = registry["relations.people"]

    expect(users.to_a).to eql([{uuid: "uuid-value", name: "name-value"}])
  end

  it "can define a relation inheriting an abstract dataset" do
    setup.gateway(:default)

    setup.dataset(id: :joe, abstract: true) do
      insert(name: "Joe")
    end

    setup.dataset(id: :jane, abstract: true) do
      insert(name: "Jane")
    end

    setup.relation(:people) do
      dataset do |_schema|
        order(:name)
      end
    end

    users = registry["relations.people"]

    expect(setup.components.get(:datasets, id: :people)).to_not be_abstract
    expect(users.to_a).to eql([{name: "Jane"}, {name: "Joe"}])
  end

  it "can define commands" do
    setup.gateway(:default)

    setup.relation(:users)

    commands = setup.commands(:users) do
      define(:create)
    end

    expect(commands.size).to be(1)

    component = commands.first

    expect(component.config.id).to be(:create)
    expect(component.config.adapter).to be(:memory)
    expect(component.config.relation).to be(:users)

    command = registry["commands.users.create"]

    expect(command).to be_a(ROM::Memory::Commands::Create)
  end

  it "can define mappers" do
    mappers = setup.mappers do
      define(:users)
      define(:tasks)
    end

    expect(mappers.size).to be(2)

    users_mapper, tasks_mapper = mappers.to_a

    expect(users_mapper.id).to be(:users)
    expect(users_mapper.relation).to be(:users)
    expect(users_mapper.namespace).to eql("mappers.users")

    expect(tasks_mapper.id).to be(:tasks)
    expect(tasks_mapper.relation).to be(:tasks)
    expect(tasks_mapper.namespace).to eql("mappers.tasks")
  end

  it "can define mappers in a custom namespace" do
    mappers = setup.mappers(:serializers) do
      define(:users)
      define(:tasks)
      define(:json, parent: :tasks)
    end

    expect(mappers.size).to be(3)

    users_mapper, tasks_mapper, json_mapper = mappers.to_a

    expect(users_mapper.id).to be(:users)
    expect(users_mapper.relation).to be(:users)
    expect(users_mapper.namespace).to eql("mappers.serializers.users")

    expect(tasks_mapper.id).to be(:tasks)
    expect(tasks_mapper.relation).to be(:tasks)
    expect(tasks_mapper.namespace).to eql("mappers.serializers.tasks")
    expect(tasks_mapper.key).to eql("mappers.serializers.tasks.tasks")

    expect(json_mapper.id).to be(:json)
    expect(json_mapper.relation).to be(:tasks)
    expect(json_mapper.namespace).to eql("mappers.serializers.tasks")
    expect(json_mapper.key).to eql("mappers.serializers.tasks.json")
  end

  it "can define top-level associations" do
    associations = setup.associations(source: :users) do
      has_many :tasks
    end

    expect(associations.size).to be(1)

    tasks, * = associations

    expect(tasks.id).to be(:tasks)
    expect(tasks.key).to eql("associations.users.tasks")
  end

  it "can define relation associations" do
    setup.gateway(:default)

    setup.relation(:users) do
      associations do
        has_many :tasks
      end
    end

    associations = setup.components.associations

    expect(associations.size).to be(1)

    tasks, * = associations

    expect(tasks.id).to be(:tasks)
    expect(tasks.key).to eql("associations.users.tasks")

    expect(registry.relations[:users].associations[:tasks])
      .to be_a(ROM::Memory::Associations::OneToMany)
  end

  it "can define a local plugin" do
    setup.gateway(:default)

    plugin = setup.plugin(:memory, schemas: :timestamps) { |config|
      config.attributes = %w[foo bar]
    }

    expect(plugin.key).to eql("schema.timestamps")
    expect(plugin).to_not be(ROM.plugins[plugin.key])
    expect(plugin.config.attributes).to eql(%w[foo bar])
  end

  it "can define a local plugin after a component was registered" do
    setup.relation(:users, adapter: :memory)

    setup.plugin(:memory, relations: :instrumentation) do |config|
      config.notifications = double(:notifications)
    end

    expect(registry.relations[:users]).to respond_to(:notifications)
  end
end
