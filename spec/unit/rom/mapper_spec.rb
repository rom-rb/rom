require 'spec_helper'
require 'rom/memory/dataset'

require 'ostruct'

describe ROM::Mapper do
  subject(:mapper) { mapper_class.build }

  let(:mapper_class) do
    user_model = self.user_model

    Class.new(ROM::Mapper) do
      attribute :id
      attribute :name
      model user_model
    end
  end

  let(:relation) do
    ROM::Relation.new(dataset)
  end

  let(:dataset) do
    ROM::Memory::Dataset.new(
      [{ id: 1, name: 'Jane' }, { id: 2, name: 'Joe' }]
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

      mapper.process(relation).each do |tuple|
        result << tuple
      end

      expect(result).to eql([jane, joe])
    end
  end
end
