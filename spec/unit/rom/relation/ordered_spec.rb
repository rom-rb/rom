require 'spec_helper'

describe Relation, '#ordered' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { Axiom::Relation.new([[ :name, String ]], [['John'], ['Jane']]) }
  let(:mapper)         { Mapper.new }

  it 'returns ordered relation by its attributes' do
    expect(relation.ordered.all).to eql([{ :name => 'Jane' }, { :name => 'John' }])
  end
end
