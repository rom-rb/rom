require 'spec_helper'

describe Relation, '#update' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { Axiom::Relation.new([[ :name, String ]], [[ 'John' ]]) }
  let(:mapper)         { Mapper.new }

  it 'updates old tuples with new ones' do
    expect(relation.update([['John']], [['Jane']]).all).to eql([{ :name => 'Jane' }])
  end
end
