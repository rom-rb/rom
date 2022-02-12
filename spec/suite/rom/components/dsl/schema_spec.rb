# frozen_string_literal: true

require "rom/core"

RSpec.describe ROM::Components::DSL, "#schema" do
  subject(:setup) do
    ROM::Setup.new
  end

  let(:schema) do
    setup.registry["schemas.users"]
  end

  it "defines an empty schema by default" do
    setup.schema(:users)

    expect(schema.name.dataset).to be(:users)
    expect(schema).to be_empty
  end

  it "defines an empty schema with attributes" do
    setup.schema(:users) do
      attribute(:id, Types::Integer)
      attribute(:name, Types::String)
    end

    expect(schema.to_a.size).to be(2)

    id, name = schema

    expect(id).to be_a(ROM::Attribute)
    expect(id.primitive).to eql(Integer)
    expect(id.meta[:source].relation).to be(:users)

    expect(name).to be_a(ROM::Attribute)
    expect(name.primitive).to eql(String)
    expect(name.meta[:source].relation).to be(:users)
  end
end
