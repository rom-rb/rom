require 'spec_helper'

describe Relation, '#first' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { Axiom::Relation.new([[ :name, String ]], [['John'], ['Jane']]) }
  let(:mapper)         { Mapper.new }

  it 'returns first tuple' do
    pending
  end
end
