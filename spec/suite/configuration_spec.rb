# frozen_string_literal: true

require "rom/configuration"

RSpec.describe ROM::Configuration do
  subject(:configuration) do
    ROM::Configuration.new(:memory)
  end

  it "can define a dataset" do
    dataset = configuration.dataset(:users)

    expect(dataset.id).to be(:users)
    expect(dataset.gateway).to be(:default)
  end

  it "can define a schema" do
    pending "TODO: decouple schema component from schema_* Relation methods"

    schema = configuration.schema(:users)

    expect(schema.id).to be(:users)
    expect(schema.gateway).to be(:default)
  end

  it "can define a relation" do
    relation = configuration.relation(:users)

    expect(relation.id).to be(:users)
    expect(relation.gateway).to be(:default)
  end

  it "can define commands" do
    commands = configuration.commands(:users, adapter: :memory) do
      define(:create)
    end

    expect(commands.size).to be(1)

    command = commands.first

    expect(command.id).to be(:create)
    expect(command.adapter).to be(:memory)
    expect(command.relation_id).to be(:users)
  end

  it "can define mappers" do
    mappers = configuration.mappers do
      define(:users)
      define(:tasks)
    end

    expect(mappers.size).to be(2)

    users_mapper, tasks_mapper = mappers.to_a

    expect(users_mapper.id).to be(:users)
    expect(users_mapper.relation_id).to be(:users)

    expect(tasks_mapper.id).to be(:tasks)
    expect(tasks_mapper.relation_id).to be(:tasks)
  end

  it "can define a local plugin" do
    pending "FIXME: configuring a local plugin should copy the canonical plugin"

    plugin = configuration.plugin(:memory, schemas: :timestamps)

    expect(plugin.key).to eql("schema.timestamps")
    expect(plugin).to_not be(ROM.plugin_registry[plugin.key])
  end
end
