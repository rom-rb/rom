# frozen_string_literal: true

require "rom/schema/associations_dsl"

RSpec.describe ROM::Schema::AssociationsDSL do
  subject(:dsl) do
    ROM::Schema::AssociationsDSL.new(ROM::Relation::Name[:users]) do
      has_many :posts
    end
  end

  describe "#call" do
    it "returns a configured association set" do
      association_set = dsl.call

      expect(association_set.type).to eql("ROM::AssociationSet[:users]")
      expect(association_set.key?(:posts)).to be(true)
    end
  end
end
