require 'spec_helper'

describe Relation, '#replace' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:users)  { Axiom::Relation.new([[ :name, String ]], [[ 'John' ], [ 'Jane' ]]) }
  let(:user1)  { mock_model(name: 'John') }
  let(:user2)  { mock_model(name: 'Jane') }
  let(:mapper) { Mapper.new(users.header) }

  it 'replaces the relation with a new one' do
    expect(relation.replace([ user2 ]).all).to eq([ user2 ])
  end
end
