require 'spec_helper'

describe Session::Registry do
  subject(:registry) { described_class.new(relations, im) }

  let(:relations) {
    { :users => users }
  }

  let(:users) {
    relation = TEST_ENV.repository(:test).get(:users)
    mapper   = Mapper.new(relation.header, mock_model(:id, :name))
    Relation.new(relation, mapper)
  }

  let(:im) {
    Hash.new
  }

  describe '#[]' do
    it 'returns relation identified by a symbol' do
      relation = registry[:users]

      expect(relation.mapper).to be_kind_of(Session::Mapper)
    end
  end
end
