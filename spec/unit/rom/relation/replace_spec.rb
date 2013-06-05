require 'spec_helper'

describe Relation, '#replace' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { Axiom::Relation.new([[ :name, String ]], [[ 'John' ]]) }
  let(:mapper)         { Mapper.new }

  it 'replaces the relation with a new one' do
    expect(relation.replace([['Jane']]).all).to eql([{ :name => 'Jane' }])
  end
end
