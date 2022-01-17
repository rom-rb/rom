# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, ".dataset" do
  context "standalone class" do
    it "defines a default dataset component" do
      relation = Class.new(ROM::Relation) {
        dataset { [] }
      }.new

      expect(relation.dataset).to be_empty
      expect(relation.dataset).to be_a(Array)
    end
  end

  context "part of runtime" do
    let(:runtime) { ROM::Runtime.new }
    let(:resolver) { runtime.finalize }

    it "defines a default dataset component" do
      klass = Class.new(ROM::Relation) {
        config.component.id = :relation

        dataset { [] }
      }

      runtime.register_relation(klass)

      relation = resolver.relations[:relation]

      expect(relation.dataset).to be_empty
      expect(relation.dataset).to be_a(Array)
    end
  end

  describe "integration" do
    include_context "container"

    it "injects configured dataset when block was provided" do
      configuration.relation(:users) do
        dataset do
          insert(id: 2, name: "Joe")
          insert(id: 1, name: "Jane")

          restrict(name: "Jane")
        end
      end

      expect(container.relations[:users].to_a).to eql([{id: 1, name: "Jane"}])
    end

    it "yields schema for setting custom dataset proc" do
      configuration.relation(:users) do
        schema(:users) do
          attribute :id, ROM::Memory::Types::Integer.meta(primary_key: true)
          attribute :name, ROM::Memory::Types::String
        end

        dataset do |schema|
          insert(id: 2, name: "Joe")
          insert(id: 1, name: "Jane")

          order(*schema.primary_key.map(&:name))
        end
      end

      expect(container.relations[:users].to_a).to eql([
        {id: 1, name: "Jane"}, {id: 2, name: "Joe"}
      ])
    end
  end
end
