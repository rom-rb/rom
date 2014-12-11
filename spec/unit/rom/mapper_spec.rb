require 'spec_helper'

require 'ostruct'

describe ROM::Mapper do
  subject(:mapper) do
    ROM::Mapper.build(ROM::Header.coerce(relation.header.zip), user_model)
  end

  let(:relation) do
    ROM::Relation.new(dataset, dataset.header)
  end

  let(:dataset) do
    ROM::Adapter::Memory::Dataset.new(
      [{id: 1, name: 'Jane'}, {id: 2, name: 'Joe'}], [:id, :name]
    )
  end

  let(:user_model) do
    Class.new(OpenStruct) { include Equalizer.new(:id, :name) }
  end

  let(:jane) { user_model.new(id: 1, name: 'Jane') }
  let(:joe) { user_model.new(id: 2, name: 'Joe') }

  describe "#each" do
    it "yields all mapped objects" do
      result = []

      relation.each do |tuple|
        result << mapper.load(tuple)
      end

      expect(result).to eql([jane, joe])
    end
  end

end
