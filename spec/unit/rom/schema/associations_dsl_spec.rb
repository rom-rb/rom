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
      associations = dsl.call

      expect(associations.map(&:name)).to include(:posts)
    end

    context "using custom inflector" do
      let(:inflector) do
        Dry::Inflector.new do |i|
          i.singular("labels", "tag")
        end
      end

      let(:args) { [*super(), inflector] }

      specify do
        associations = dsl.call

        expect(associations.last.options[:through].assoc_name).to eql(:tag)
      end
    end
  end
end
