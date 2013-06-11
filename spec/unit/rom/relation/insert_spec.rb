require 'spec_helper'

describe Relation, '#insert' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:users)  { Axiom::Relation.new([[ :name, String ]], [[ 'John' ]]) }
  let(:user)   { mock_model(name: 'Jane') }
  let(:mapper) { Mapper.new(users.header) }

  it 'inserts dumped object into relation' do
    expect(relation.insert(user).all).to include(user)
  end
end
