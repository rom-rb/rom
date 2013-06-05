require 'spec_helper'

describe Relation, '#take' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { Axiom::Relation.new([[ :name, String ]], [['John'], ['Jane']]) }
  let(:mapper)         { Mapper.new }

  it 'limits the relation' do
    pending
    expect(relation.take(1).all).to eql([{ :name => 'John' }])
  end
end
