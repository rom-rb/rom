require 'spec_helper'

describe Relation do
  subject(:relation) { Relation.new(DB[:users]) }

  let(:jane) { { id: 1, name: 'Jane' } }
  let(:joe) { { id: 2, name: 'Joe' } }

  describe "#each" do
    it "yields all objects" do
      result = []

      relation.each do |user|
        result << user
      end

      expect(result).to eql([jane, joe])
    end
  end

  describe '#where' do
    it 'forwards to the dataset' do
      expect(relation.where(name: 'Joe').first).to eql(joe)
    end
  end

end
