require 'spec_helper'

describe Relation, '#delete' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:users)  { Axiom::Relation.new([[ :name, String ]], [[ 'John' ]]) }
  let(:user)   { mock_model(name: 'John') }
  let(:mapper) { Mapper.new(users.header) }

  it 'deletes tuples from the relation' do
    expect(relation.delete(user).all).to be_empty
  end
end
