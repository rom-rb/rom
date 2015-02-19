require 'spec_helper'

describe ROM::Relation::Loaded do
  include_context 'users and tasks'

  subject(:users) { ROM::Relation::Loaded.new(rom.relations.users, mappers) }

  let(:mappers) { {} }

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

  describe '#as' do
    let(:mappers) { { email_list: email_mapper, upcase: upcase_mapper } }
    let(:email_mapper) { proc { |data| data.map { |t| t[:email] } } }
    let(:upcase_mapper) { proc { |data| data.map(&:upcase) } }

    it 'maps relation using specified mapper' do
      expect(users.as(:email_list)).to match_array(
        %w(joe@doe.org jane@doe.org)
      )
    end

    it 'allows mappping with multiple mappers' do
      expect(users.as(:email_list, :upcase)).to match_array(
        %w(JOE@DOE.ORG JANE@DOE.ORG)
      )
    end

    describe 'enumerable chaining' do
      it 'allows chain enumerable method calls' do
        result = users.as(:email_list).take(1).map(&:upcase)
        expect(result).to match_array(%w(JOE@DOE.ORG))
      end
    end
  end
end
