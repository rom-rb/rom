# frozen_string_literal: true

require "rom"
require "rom/relation"

RSpec.describe ROM::Relation, ".schema" do
  context "standalone class" do
    it "defines a default schema component" do
      pending "TODO: this requires schema inference"

      relation = Class.new(ROM::Relation).new([])

      expect(relation.schema).to be_empty
      expect(relation.schema.name.to_sym).to be(:relation)
    end
  end

  context "part of runtime" do
    let(:rom) { ROM.container(configuration) }

    let(:configuration) { ROM::Configuration.new }

    it "defines a default schema component" do
      klass = Class.new(ROM::Relation[:memory]) {
        schema { }
      }

      configuration.register_relation(klass)

      relation = rom.relations[:relation]

      expect(relation.schema).to be_empty
      expect(relation.schema.name.to_sym).to be(:relation)
    end

    it "defines a schema with a custom id" do
      klass = Class.new(ROM::Relation[:memory]) {
        schema(:users) { }
      }

      configuration.register_relation(klass)

      relation = rom.relations[:relation]

      expect(relation.schema).to be_empty
      expect(relation.schema.name.to_sym).to be(:users)
    end

    it "defines a schema with a custom id inferred from class name" do
      module Test
        class Users < ROM::Relation[:memory]
          schema { }
        end
      end

      configuration.register_relation(Test::Users)

      relation = rom.relations[:users]

      expect(relation.schema).to be_empty
      expect(relation.schema.name.to_sym).to be(:users)
    end
  end
end
