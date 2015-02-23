require 'spec_helper'

describe ROM::Relation::Loaded do
  include_context 'users and tasks'

  subject(:users) { ROM::Relation::Loaded.new(rom.relations.users) }

  before { setup.relation(:users) }

  describe '#each' do
    it 'yields tuples from relation' do
      result = []
      users.each { |tuple| result << tuple }
      expect(result).to match_array([
        { name: 'Jane', email: 'jane@doe.org' },
        { name: 'Joe', email: 'joe@doe.org' }
      ])
    end

    it 'returns enumerator when block is not provided' do
      expect(users.each.to_a).to eql(users.relation.to_a)
    end
  end

  describe '#one' do
    it 'returns first tuple' do
      rom.relations.users.delete(name: 'Joe', email: 'joe@doe.org')
      expect(users.one).to eql(name: 'Jane', email: 'jane@doe.org')
    end

    it 'raises error when there is more than one tuple' do
      expect { users.one }.to raise_error(ROM::TupleCountMismatchError)
    end
  end

  describe '#one!' do
    it 'returns first tuple' do
      rom.relations.users.delete(name: 'Joe', email: 'joe@doe.org')
      expect(users.one!).to eql(name: 'Jane', email: 'jane@doe.org')
    end

    it 'raises error when there is no tuples' do
      rom.relations.users.delete(name: 'Jane', email: 'jane@doe.org')
      rom.relations.users.delete(name: 'Joe', email: 'joe@doe.org')

      expect { users.one! }.to raise_error(ROM::TupleCountMismatchError)
    end
  end
end
