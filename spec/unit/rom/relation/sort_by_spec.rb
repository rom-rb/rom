require 'spec_helper'

describe Relation, '#sort_by' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { Axiom::Relation.new([[ :name, String ]], [['John'], ['Jane']]) }
  let(:mapper)         { Mapper.new }

  it 'sorts relation by its attributes' do
    expect(relation.sort_by { |r| [ r.name ] }.all).to eql([{ :name => 'Jane' }, { :name => 'John' }])
  end
end
