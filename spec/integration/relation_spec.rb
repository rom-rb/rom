require 'spec_helper'

describe Relation do
  subject(:relation) { Relation.new(DB[:users]) }

  let(:jane) { { id: 1, name: 'Jane' } }
  let(:joe) { { id: 2, name: 'Joe' } }

  before do
    seed
  end

  after do
    deseed
  end

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

  describe '#select' do
    it 'forwards to the dataset' do
      expect(relation.select(:id).to_a).to eql([{id: 1}, {id: 2}])
    end
  end

  describe '#insert' do
    it 'returns relation with inserted tuple' do
      tuple = { name: 'Jade' }
      users = relation.insert(tuple)

      expect(users.where(name: 'Jade').first).to include(tuple)
    end
  end

end
