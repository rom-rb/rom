# encoding: utf-8

require 'spec_helper'

describe Relation, '#to_a' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { [1, 2] }
  let(:loaded_objects) { %w(1 2) }
  fake(:mapper)

  before do
    stub(mapper).load(1) { '1' }
    stub(mapper).load(2) { '2' }
  end

  it 'gets all tuples and loads them via mapper' do
    expect(relation.to_a).to eql(loaded_objects)
  end
end
