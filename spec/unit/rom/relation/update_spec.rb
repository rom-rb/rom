require 'spec_helper'

describe Relation, '#update' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:users)  { Axiom::Relation::Variable.new(Axiom::Relation.new([[ :name, String ]], [[ 'John' ]])) }
  let(:model)  { mock_model(:name) }
  let(:user)   { model.new(name: 'John') }
  let(:mapper) { TestMapper.new(users.header, model) }

  it 'updates old tuples with new ones' do
    expect(relation.update(user).all).to eq([ user ])
  end
end
