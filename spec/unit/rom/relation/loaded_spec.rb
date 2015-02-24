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
      expect(users.each.to_a).to eql(users.collection.to_a)
    end
  end

  it_behaves_like 'a relation that returns one tuple' do
    let(:relation) { users }
  end
end
