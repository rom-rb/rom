# frozen_string_literal: true

require "rom/runtime"

RSpec.describe ROM::Runtime do
  subject(:runtime) do
    ROM::Runtime.new { |runtime|
      runtime.config.component.adapter = :memory
    }
  end

  let(:resolver) do
    runtime.resolver
  end

  it "can define a dataset" do
    dataset = runtime.dataset(:users) { [1, 2] }

    expect(dataset.config[:id]).to be(:users)
    expect(dataset.config[:gateway]).to be(:default)

    expect(resolver["datasets.users"]).to eql([1, 2])
  end

  it "can define a dataset with a gateway" do
    runtime.gateway(:default)
    runtime.dataset(:users)

    expect(resolver["datasets.users"]).to be_a(ROM::Memory::Dataset)
  end

  it "can define a schema" do
    schema = runtime.schema(:users)

    expect(schema.config.id).to be(:users)
    expect(schema.config.gateway).to be(:default)

    expect(resolver["schemas.users"]).to be_a(ROM::Schema)
  end

  it "can define a relation" do
    runtime.gateway(:default)
    runtime.dataset(:users)

    relation = runtime.relation(:users)

    expect(relation.config.id).to be(:users)
    expect(relation.config.dataset).to be(:users)
    expect(relation.config.gateway).to be(:default)

    users = resolver["relations.users"]

    expect(users).to be_a(ROM::Memory::Relation)
    expect(users.dataset).to be_a(ROM::Memory::Dataset)
  end

  it "can define a relation with a schema" do
    runtime.gateway(:default)

    relation = runtime.relation(:users) do
      schema { attribute(:id, ROM::Types::Integer) }
    end

    expect(relation.config.id).to be(:users)
    expect(relation.config.dataset).to be(:users)
    expect(relation.config.gateway).to be(:default)

    users = resolver["relations.users"]

    expect(users).to be_a(ROM::Memory::Relation)
    expect(users.schema).to be_a(ROM::Schema)
    expect(users.schema[:id]).to be_a(ROM::Attribute)
  end

  it "can define a relation with a schema with its own dataset id" do
    runtime.gateway(:default)

    relation = runtime.relation(:people) do
      schema(dataset: :users) { attribute(:id, ROM::Types::Integer) }
    end

    expect(relation.config.id).to be(:people)
    expect(relation.config.gateway).to be(:default)

    users = resolver["relations.people"]
    schema = resolver["schemas.people"]

    expect(users).to be_a(ROM::Memory::Relation)
    expect(users.name.dataset).to be(:users)

    expect(users.schema).to be(schema)
    expect(users.schema).to be_a(ROM::Schema)
    expect(users.schema[:id]).to be_a(ROM::Attribute)
  end

  it "can define a relation with a schema and a dataset" do
    runtime.gateway(:default)

    relation = runtime.relation(:people) do
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

    users = resolver["relations.people"]

    expect(users.to_a).to eql([{uuid: "uuid-value", name: "name-value"}])
  end

  it "can define a relation inheriting an abstract dataset" do
    runtime.gateway(:default)

    runtime.dataset(id: :joe, abstract: true) do
      insert(name: "Joe")
    end

    runtime.dataset(id: :jane, abstract: true) do
      insert(name: "Jane")
    end

    relation = runtime.relation(:people) do
      dataset do |schema|
        order(:name)
      end
    end

    users = resolver["relations.people"]

    expect(runtime.components.get(:datasets, id: :people)).to_not be_abstract
    expect(users.to_a).to eql([{name: "Jane"}, {name: "Joe"}])
  end

  it "can define commands" do
    runtime.gateway(:default)

    runtime.relation(:users)

    commands = runtime.commands(:users) do
      define(:create)
    end

    expect(commands.size).to be(1)

    component = commands.first

    expect(component.config.id).to be(:create)
    expect(component.config.adapter).to be(:memory)
    expect(component.config.relation).to be(:users)

    command = resolver["commands.users.create"]

    expect(command).to be_a(ROM::Memory::Commands::Create)
  end

  it "can define mappers" do
    mappers = runtime.mappers do
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
    mappers = runtime.mappers(:serializers) do
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
    associations = runtime.associations(source: :users) do
      has_many :tasks
    end

    expect(associations.size).to be(1)

    tasks, * = associations

    expect(tasks.id).to be(:tasks)
    expect(tasks.key).to eql("associations.users.tasks")
  end

  it "can define relation associations" do
    runtime.relation(:users) do
      associations do
        has_many :tasks
      end
    end

    associations = runtime.components.associations

    expect(associations.size).to be(1)

    tasks, * = associations

    expect(tasks.id).to be(:tasks)
    expect(tasks.key).to eql("associations.users.tasks")

    expect(resolver.relations[:users].associations[:tasks])
      .to be_a(ROM::Memory::Associations::OneToMany)
  end

  it "can define a local plugin" do
    plugin = runtime.plugin(:memory, schemas: :timestamps) { |config|
      config.attributes = %w[foo bar]
    }

    expect(plugin.key).to eql("schema.timestamps")
    expect(plugin).to_not be(ROM.plugins[plugin.key])
    expect(plugin.config.attributes).to eql(%w[foo bar])
  end
end
