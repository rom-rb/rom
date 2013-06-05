require 'spec_helper'

describe Relation, '#drop' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { Axiom::Relation.new([[ :name, String ]], [['John'], ['Jane']]) }
  let(:mapper)         { Mapper.new }

  it 'drops the relation by the given offset' do
    pending
  end
end
