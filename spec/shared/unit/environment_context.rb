shared_context 'Session::Environment' do
  let(:object) { described_class.new({ :users => users }, Session::Tracker.new) }

  let(:users) {
    relation = TEST_ENV.repository(:test).get(:users)
    mapper   = Mapper.new(relation.header, mock_model(:id, :name))
    Relation.new(relation, mapper)
  }
end
