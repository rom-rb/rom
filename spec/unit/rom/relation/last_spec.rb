require 'spec_helper'

describe Relation, '#first' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:users)  { Axiom::Relation.new([[ :name, String ]], [['John'], ['Jane']]) }
  let(:model)  { mock_model(:name) }
  let(:mapper) { TestMapper.new(users.header, model) }

  it 'returns first object from the relation' do
    expect(relation.last).to eq(model.new(:name => 'John'))
  end
end
