require 'spec_helper'

describe Relation, '#restrict' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:users)  { Axiom::Relation.new([[ :name, String ]], [[ 'John' ], [ 'Jane' ]]) }
  let(:model)  { mock_model(:name) }
  let(:user1)  { model.new(name: 'John') }
  let(:user2)  { model.new(name: 'Jane') }
  let(:mapper) { TestMapper.new(users.header, model) }

  it 'restricts the relation' do
    expect(relation.restrict(:name => 'Jane').all).to eq([ user2 ])
  end
end
