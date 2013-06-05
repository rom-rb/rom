require 'spec_helper'

describe Relation, '#restrict' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { Axiom::Relation.new([[ :name, String ]], [['John'], ['Jane']]) }
  let(:mapper)         { Mapper.new }

  it 'restricts the relation' do
    expect(relation.restrict(:name => 'Jane').all).to eql([{ :name => 'Jane' }])
  end
end
