shared_context 'Relation' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:header) { [[:name, String]] }
  let(:users)  { Axiom::Relation.new(header, [['John'], ['Jane']]) }

  let(:model)  { mock_model(:name) }
  let(:mapper) { TestMapper.new(users.header, model) }

  let(:user1)  { model.new(name: 'John') }
  let(:user2)  { model.new(name: 'Jane') }
end
