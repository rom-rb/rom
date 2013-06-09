require 'spec_helper'

describe Relation, '#update' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:users)  { Axiom::Relation.new([[ :name, String ]], [[ 'John' ]]) }
  let(:user)   { mock_model(name: 'John') }
  let(:mapper) { Mapper.new(users.header) }

  it 'updates old tuples with new ones' do
    expect(relation.update(user).all).to eq([ user ])
  end
end
