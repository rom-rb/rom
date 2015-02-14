require 'spec_helper'

describe ROM::Relation::Loaded do
  include_context 'users and tasks'

  subject(:users) { ROM::Relation::Loaded.new(rom.relations.users, mappers) }

  let(:mappers) { {} }

  before { setup.relation(:users) }

  describe '#first' do
    it 'returns first tuple' do
      expect(users.first).to eql(name: 'Joe', email: 'joe@doe.org')
    end
  end

  describe '#map' do
    let(:mappers) { { email_list: email_mapper, upcase: upcase_mapper } }
    let(:email_mapper) { proc { |data| data.map { |t| t[:email] } } }
    let(:upcase_mapper) { proc { |data| data.map(&:upcase) } }

    it 'maps relation using specified mapper' do
      expect(users.map_with(:email_list)).to match_array(
        %w(joe@doe.org jane@doe.org)
      )
    end

    it 'allows mappping with multiple mappers' do
      expect(users.map_with(:email_list, :upcase)).to match_array(
        %w(JOE@DOE.ORG JANE@DOE.ORG)
      )
    end

    describe 'enumerable chaining' do
      it 'allows chain enumerable method calls' do
        result = users.map_with(:email_list).take(1).map(&:upcase)
        expect(result).to match_array(%w(JOE@DOE.ORG))
      end
    end
  end
end
