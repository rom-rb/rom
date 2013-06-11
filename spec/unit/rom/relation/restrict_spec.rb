require 'spec_helper'

describe Relation, '#restrict' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:users)  { Axiom::Relation.new([[ :name, String ]], [[ 'John' ], [ 'Jane' ]]) }
  let(:user1)  { mock_model(name: 'John') }
  let(:user2)  { mock_model(name: 'Jane') }
  let(:mapper) { Mapper.new(users.header) }

  it 'restricts the relation' do
    expect(relation.restrict(:name => 'Jane').all).to eq([ user2 ])
  end
end
