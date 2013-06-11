require 'spec_helper'

describe Relation, '#ordered' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:users)  { Axiom::Relation.new([[ :name, String ]], [[ 'John' ], [ 'Jane' ]]) }
  let(:user1)  { mock_model(name: 'John') }
  let(:user2)  { mock_model(name: 'Jane') }
  let(:mapper) { Mapper.new(users.header) }

  it 'returns ordered relation by its attributes' do
    expect(relation.ordered.all).to eq([ user2, user1 ])
  end
end
