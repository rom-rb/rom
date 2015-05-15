require 'spec_helper'
require 'rom/lint/spec'

require 'rom/memory/dataset'
require 'rom/memory/relation'

describe ROM::Memory::Relation do
  subject(:relation) { ROM::Memory::Relation.new(dataset) }

  let(:dataset) do
    ROM::Memory::Dataset.new([
      { name: 'Jane', email: 'jane@doe.org', age: 10 },
      { name: 'Jade', email: 'jade@doe.org', age: 11 },
      { name: 'Joe',  email: 'joe@doe.org', age: 12 },
      { name: 'Jack', email: nil, age: 9 },
    ])
  end

  describe '#take' do
    it 'takes given number of tuples' do
      expect(relation.take(2)).to match_array([
        { name: 'Jane', email: 'jane@doe.org', age: 10 },
        { name: 'Jade', email: 'jade@doe.org', age: 11 }
      ])
    end
  end

  describe '#project' do
    it 'projects tuples with the provided keys' do
      expect(relation.project(:name, :age)).to match_array([
        { name: 'Jane', age: 10 },
        { name: 'Jade', age: 11 },
        { name: 'Joe', age: 12 },
        { name: 'Jack', age: 9 }
      ])
    end
  end

  describe '#restrict' do
    it 'restricts data using criteria hash' do
      expect(relation.restrict(age: 10)).to match_array([
        { name: 'Jane', email: 'jane@doe.org', age: 10 }
      ])

      expect(relation.restrict(age: 10.0)).to match_array([])
    end

    it 'restricts data using block' do
      expect(relation.restrict { |tuple| tuple[:age] > 10 }).to match_array([
        { name: 'Jade', email: 'jade@doe.org', age: 11 },
        { name: 'Joe', email: 'joe@doe.org', age: 12 }
      ])
    end
  end

  describe '#order' do
    it 'sorts data using provided attribute names' do
      expect(relation.order(:email).to_a).to eq([
        { name: 'Jade', email: 'jade@doe.org', age: 11 },
        { name: 'Jane', email: 'jane@doe.org', age: 10 },
        { name: 'Joe',  email: 'joe@doe.org',  age: 12 },
        { name: 'Jack', email: nil, age: 9 }
      ])
    end

    it 'places nil before other values when required' do
      expect(relation.order(:email, nils_first: true).to_a).to eq([
        { name: 'Jack', email: nil, age: 9 },
        { name: 'Jade', email: 'jade@doe.org', age: 11 },
        { name: 'Jane', email: 'jane@doe.org', age: 10 },
        { name: 'Joe',  email: 'joe@doe.org',  age: 12 }
      ])
    end
  end
end
