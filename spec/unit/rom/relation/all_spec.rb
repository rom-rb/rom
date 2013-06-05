require 'spec_helper'

describe Relation, '#all' do
  subject(:relation) { described_class.new(axiom_relation, mapper) }

  let(:axiom_relation) { [ 1, 2 ] }
  let(:mapper)         { mock('mapper') }

  it 'gets all tuples and loads them via mapper' do
    mapper.should_receive(:load).with(1).and_return('1')
    mapper.should_receive(:load).with(2).and_return('2')

    expect(relation.all).to eql([ '1', '2' ])
  end
end
