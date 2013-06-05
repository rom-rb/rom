require 'spec_helper'

describe Relation, '#delete' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { Axiom::Relation.new([[ :name, String ]], [[ 'John' ]]) }
  let(:mapper)         { Mapper.new }

  it 'deletes tuples from the relation' do
    expect(relation.delete([['John']]).all).to be_empty
  end
end
