# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#schema" do
  it "returns schema inferred from demodulized class name" do
    module Test
      class Users < ROM::Relation[:memory]
      end
    end

    relation = Test::Users.new([])

    expect(relation.name.dataset).to be(:users)
    expect(relation.name.relation).to be(:users)

    expect(relation.schema.name.dataset).to be(:users)
    expect(relation.schema.name.relation).to be(:users)
  end

  it "returns schema that's explicitly defined" do
    module Test
      class Users < ROM::Relation[:memory]
        schema(:people)
      end
    end

    relation = Test::Users.new([])

    expect(relation.name.dataset).to be(:people)
    expect(relation.name.relation).to be(:users)

    expect(relation.schema.name.dataset).to be(:people)
    expect(relation.schema.name.relation).to be(:users)
  end

  context "with a registry" do
    subject(:relation) do
      registry.relations[:users]
    end

    let(:registry) do
      setup.registry
    end

    let(:setup) do
      ROM::Setup.new(:memory)
    end

    let(:schema) do
      relation.schema
    end

    it "returns an inferred empty schema by default" do
      setup.relation(:users)

      expect(schema).to be_empty
      expect(schema.name.relation).to be(:users)
      expect(schema.name.dataset).to be(:users)
    end

    it "returns explictly defined schema" do
      setup.relation(:users) do
        schema do
          attribute :id, ROM::Types::Integer
          attribute :name, ROM::Types::Integer
        end
      end

      expect(schema).to_not be_empty
      expect(schema.name.relation).to be(:users)
      expect(schema.name.dataset).to be(:users)
    end

    it "returns explictly defined schema with a custom dataset" do
      setup.relation(:users) do
        schema(:people) do
          attribute :id, ROM::Types::Integer
          attribute :name, ROM::Types::Integer
        end
      end

      expect(schema).to_not be_empty
      expect(schema.name.relation).to be(:users)
      expect(schema.name.dataset).to be(:people)
    end
  end
end
