require 'spec_helper'

describe Relation, '#order' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { Axiom::Relation.new([[ :name, String ]], [['John'], ['Jane']]) }
  let(:mapper)         { Mapper.new }

  it 'orders relation by its attributes' do
    expect(relation.order(:name).all).to eql([{ :name => 'Jane' }, { :name => 'John' }])
  end
end
