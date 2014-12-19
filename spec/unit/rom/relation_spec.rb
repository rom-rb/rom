require 'spec_helper'

describe ROM::Relation do
  subject(:relation) { ROM::Relation.new(dataset, dataset.header) }

  let(:dataset) { ROM::Adapter::Memory::Dataset.new([jane, joe], [:id, :name]) }

  let(:jane) { { id: 1, name: 'Jane' } }
  let(:joe) { { id: 2, name: 'Joe' } }

  describe "#header" do
    it "return's duplicated and frozen dataset header" do
      expect(relation.header).to be_frozen
      expect(relation.header).not_to be(dataset.header)
    end
  end

  describe "#each" do
    it "yields all objects" do
      result = []

      relation.each do |user|
        result << user
      end

      expect(result).to eql([jane, joe])
    end

    it "returns an enumerator if block is not provided" do
      expect(relation.each).to be_instance_of(Enumerator)
    end
  end
end
