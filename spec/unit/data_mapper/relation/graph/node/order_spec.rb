require 'spec_helper'

describe Relation::Graph::Node, '#order' do
  subject { object.order(*names) }

  let(:object)    { described_class.new(:users, relation) }
  let(:relation)  { mock('relation') }
  let(:sorted)    { mock('sorted') }
  let(:names)     { [ :id, :age, :name ] }
  let(:evaluator) { mock('evaluator') }

  before do
    relation.should_receive(:sort_by).and_yield(evaluator).and_return(sorted)
    names.each { |name| evaluator.should_receive(name).and_return(name) }
  end

  it { should be_instance_of(described_class) }

  its(:relation) { should be(sorted) }
  its(:header)   { should be(object.header) }
end
