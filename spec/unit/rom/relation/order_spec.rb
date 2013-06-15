require 'spec_helper'

describe Relation, '#order' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:users)  { Axiom::Relation.new([[ :name, String ]], [[ 'John' ], [ 'Jane' ]]) }
  let(:model)  { mock_model(:name) }
  let(:user1)  { model.new(name: 'John') }
  let(:user2)  { model.new(name: 'Jane') }
  let(:mapper) { TestMapper.new(users.header, model) }

  it 'orders relation by its attributes' do
    expect(relation.order(:name).all).to eq([ user2, user1 ])
  end
end
