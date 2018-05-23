require 'spec_helper'
require 'rom/lint/spec'

require 'rom/memory/dataset'
require 'rom/memory/relation'

RSpec.describe ROM::Memory::Relation do
  subject(:relation) do
    Class.new(ROM::Memory::Relation) do
      schema do
        attribute :name, ROM::Types::String
        attribute :email, ROM::Types::String
        attribute :age, ROM::Types::Integer
      end
    end.new(dataset)
  end

  let(:dataset) do
    ROM::Memory::Dataset.new([
      { name: 'Jane', email: 'jane@doe.org', age: 10 },
      { name: 'Jade', email: 'jade@doe.org', age: 11 },
      { name: 'Joe',  email: 'joe@doe.org',  age: 12 },
      { name: 'Jack',                        age: 11 },
      { name: 'Jill', email: 'jill@doe.org'          },
      { name: 'John'                                 },
      { name: 'Judy', email: 'judy@doe.org', age: 11 }
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
      projected = relation.project(:name, :age)

      expect(projected.schema).to eql(relation.schema.project(:name, :age))

      expect(projected).to match_array([
        { name: 'Jane', age: 10 },
        { name: 'Jade', age: 11 },
        { name: 'Joe',  age: 12 },
        { name: 'Jack', age: 11 },
        { name: 'Jill'          },
        { name: 'John'          },
        { name: 'Judy', age: 11 }
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
        { name: 'Jack',                        age: 11 },
        { name: 'Judy', email: 'judy@doe.org', age: 11 }
      ])
    end

    it 'allows to use array as a value' do
      expect(relation.restrict(age: [10, 11])).to match_array([
        { name: 'Jane', email: 'jane@doe.org', age: 10 },
        { name: 'Jade', email: 'jade@doe.org', age: 11 },
        { name: 'Jack',                        age: 11 },
        { name: 'Judy', email: 'judy@doe.org', age: 11 }
      ])
    end

    it 'allows to use regexp as a value' do
      expect(relation.restrict(name: /\w{4}/)).to match_array([
        { name: 'Jane', email: 'jane@doe.org', age: 10 },
        { name: 'Jade', email: 'jade@doe.org', age: 11 },
        { name: 'Jack',                        age: 11 },
        { name: 'Jill', email: 'jill@doe.org'          },
        { name: 'John'                                 },
        { name: 'Judy', email: 'judy@doe.org', age: 11 }
      ])
    end
  end

  describe '#order' do
    it 'sorts data using provided attribute names' do
      expect(relation.order(:age, :email).to_a).to eq([
        { name: 'Jane', age: 10, email: 'jane@doe.org' },
        { name: 'Jade', age: 11, email: 'jade@doe.org' },
        { name: 'Judy', age: 11, email: 'judy@doe.org' },
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
        { name: 'Judy', age: 11, email: 'judy@doe.org' },
        { name: 'Joe',  age: 12, email: 'joe@doe.org'  }
      ])
    end
  end

  describe '#mappers' do
    it 'uses custom mapper compiler' do
      expect(relation.mappers.compiler).to be_instance_of(ROM::Memory::MapperCompiler)
    end
  end
end
