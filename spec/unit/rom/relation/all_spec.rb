require 'spec_helper'

describe Relation, '#all' do
  subject(:relation) { described_class.new(relation_node, mapper) }

  let(:relation_node) { [ 1, 2 ] }
  fake(:mapper)

  before do
    stub(mapper).load(1) { '1' }
    stub(mapper).load(2) { '2' }
  end

  it 'gets all tuples and loads them via mapper' do
    expect(relation.all).to eql([ '1', '2' ])
  end
end
