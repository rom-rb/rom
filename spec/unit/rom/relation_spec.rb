require 'spec_helper'

describe Relation do
  subject(:relation) { Relation.new(dataset) }

  let(:dataset) { DB[:users] }

  let(:jane) { { id: 1, name: 'Jane' } }
  let(:joe) { { id: 2, name: 'Joe' } }

  before do
    seed
  end

  after do
    deseed
  end

  describe "#header" do
    it "return's duplicated and frozen dataset header" do
      expect(relation.header).to be_frozen
      expect(relation.header).to eql(dataset.header)
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

  describe '#update' do
    it 'returns relation with updated tuple' do
      tuple = { name: 'Jane Doe' }
      users = relation.where(id: 1).update(tuple)

      expect(users.where(name: 'Jane Doe').first).to include(tuple)
    end
  end

  describe '#delete' do
    it 'returns relation without the deleted tuple' do
      users = relation.where(id: 2).delete

      expect(users.where(id: 2)).to be_empty
    end
  end

end
