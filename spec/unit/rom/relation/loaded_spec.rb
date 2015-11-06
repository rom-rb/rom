require 'spec_helper'

describe ROM::Relation::Loaded do
  include_context 'users and tasks'

  subject(:users) { ROM::Relation::Loaded.new(container.relations.users) }

  before { configuration.relation(:users) }

  describe '#each' do
    it 'yields tuples from relation' do
      result = []
      users.each do |tuple|
        result << tuple
      end
      expect(result).to match_array([
        { name: 'Jane', email: 'jane@doe.org' },
        { name: 'Joe', email: 'joe@doe.org' }
      ])
    end

    it 'returns enumerator when block is not provided' do
      expect(users.each.to_a).to eql(users.collection.to_a)
    end
  end

  describe '#to_ary' do
    it 'coerces to an array' do
      expect(users.to_ary).to match_array([
        { name: 'Jane', email: 'jane@doe.org' },
        { name: 'Joe', email: 'joe@doe.org' }
      ])
    end
  end

  it_behaves_like 'a relation that returns one tuple' do
    let(:relation) { users }
  end
end
