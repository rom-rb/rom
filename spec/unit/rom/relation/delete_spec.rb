require 'spec_helper'

describe Relation, '#delete' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:users)  { Axiom::Relation.new([[ :name, String ]], [[ 'John' ]]) }
  let(:model)  { mock_model(:name) }
  let(:user)   { model.new(name: 'John') }
  let(:mapper) { TestMapper.new(users.header, model) }

  it 'deletes tuples from the relation' do
    expect(relation.delete(user).all).to be_empty
  end
end
