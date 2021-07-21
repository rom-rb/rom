# frozen_string_literal: true

require "rom"
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
    let(:rom) { ROM.runtime(configuration) }

    let(:configuration) { ROM::Configuration.new }

    it "defines a default dataset component" do
      pending "TODO: this requires schema inference"

      klass = Class.new(ROM::Relation) {
        dataset { [] }
      }

      configuration.register_relation(klass)

      relation = rom.relations[:relation]

      expect(relation.dataset).to be_empty
      expect(relation.dataset).to be_a(Array)
    end
  end
end
