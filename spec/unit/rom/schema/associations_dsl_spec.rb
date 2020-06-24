# frozen_string_literal: true

require "rom/schema/associations_dsl"

RSpec.describe ROM::Schema::AssociationsDSL do
  let(:args) { [ROM::Relation::Name[:users]] }

  subject(:dsl) do
    ROM::Schema::AssociationsDSL.new(*args) do
      has_many :posts
      has_many :labels, through: :posts
    end
  end

  describe "#call" do
    it "returns a configured association set" do
      association_set = dsl.call

      expect(association_set.type).to eql("ROM::AssociationSet[:users]")
      expect(association_set.key?(:posts)).to be(true)
    end

    context "using custom inflector" do
      let(:inflector) do
        Dry::Inflector.new do |i|
          i.singular("labels", "tag")
        end
      end

      let(:args) { [*super(), inflector] }

      it do
        association_set = dsl.call
        expect(association_set.type).to eql("ROM::AssociationSet[:users]")
        expect(association_set[:labels].options[:through].assoc_name).to eql(:tag)
      end
    end
  end
end
