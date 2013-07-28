shared_context 'Relation' do
  let(:users)  { Axiom::Relation.new([[:name, String]], [['John'], ['Jane']]) }
  let(:model)  { mock_model(:name) }
  let(:user)   { model.new(name: 'John') }
  let(:mapper) { TestMapper.new(users.header, model) }
end
