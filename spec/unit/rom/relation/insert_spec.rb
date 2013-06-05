require 'spec_helper'

describe Relation, '#insert' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { Axiom::Relation.new([[ :name, String ]], [[ 'John' ]]) }
  let(:mapper)         { Mapper.new }

  it 'inserts tuple into relation' do
    expect(relation.insert([['Jane']]).all).to include(:name => 'Jane')
  end
end
