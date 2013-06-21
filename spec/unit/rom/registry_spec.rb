require 'spec_helper'

describe Session::Registry do
  subject(:registry) { described_class.new(tracker) }

  let(:users) {
    relation = TEST_ENV.repository(:test).get(:users)
    mapper   = Mapper.new(relation.header, mock_model(:id, :name))
    Relation.new(relation, mapper)
  }

  let(:tracker) {
    Session::Tracker.new(:users => users)
  }

  describe '#[]' do
    it 'returns relation identified by a symbol' do
      relation = registry[:users]
      expect(relation).to be_kind_of(Session::Relation)
    end
  end
end
