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
      { name: 'Joe',  email: 'joe@doe.org',  age: 12 },
      { name: 'Jack',                        age: 11 },
      { name: 'Jill', email: 'jill@doe.org'          },
      { name: 'John'                                 }
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
        { name: 'Joe',  age: 12 },
        { name: 'Jack', age: 11 },
        { name: 'Jill'          },
        { name: 'John'          }
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
      expect(relation.restrict { |tuple| tuple[:age].to_i > 10 }).to match_array([
        { name: 'Jade', email: 'jade@doe.org', age: 11 },
        { name: 'Joe',  email: 'joe@doe.org',  age: 12 },
        { name: 'Jack',                        age: 11 }
      ])
    end
  end

  describe '#order' do
    it 'sorts data using provided attribute names' do
      expect(relation.order(:age, :email).to_a).to eq([
        { name: 'Jane', age: 10, email: 'jane@doe.org' },
        { name: 'Jade', age: 11, email: 'jade@doe.org' },
        { name: 'Jack', age: 11                        },
        { name: 'Joe',  age: 12, email: 'joe@doe.org'  },
        { name: 'Jill',          email: 'jill@doe.org' },
        { name: 'John'                                 }
      ])
    end

    it 'places nil before other values when required' do
      expect(relation.order(:age, :email, nils_first: true).to_a).to eq([
        { name: 'John'                                 },
        { name: 'Jill',          email: 'jill@doe.org' },
        { name: 'Jane', age: 10, email: 'jane@doe.org' },
        { name: 'Jack', age: 11                        },
        { name: 'Jade', age: 11, email: 'jade@doe.org' },
        { name: 'Joe',  age: 12, email: 'joe@doe.org'  }
      ])
    end
  end
end
