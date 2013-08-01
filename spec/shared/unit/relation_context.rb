# # encoding: utf-8

# encoding: utf-8

shared_context 'Relation' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:header) {
    Axiom::Relation::Header.coerce([[:id, Integer], [:name, String]], keys: [:id])
  }

  let(:users) {
    Axiom::Relation.new(header, [
      [1, 'John'], [2, 'Jane'], [3, 'Jack'], [4, 'Jade']
    ])
  }

  let(:model)  { mock_model(:id, :name) }
  let(:mapper) { TestMapper.new(users.header, model) }

  let(:john) { model.new(id: 1, name: 'John') }
  let(:jane) { model.new(id: 2, name: 'Jane') }
  let(:jack) { model.new(id: 3, name: 'Jack') }
  let(:jade) { model.new(id: 4, name: 'Jade') }
end
