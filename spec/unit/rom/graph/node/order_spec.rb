require 'spec_helper'

describe Graph::Node, '#order' do
  subject { object.order(*names) }

  let(:object)    { described_class.new(:users, relation) }
  let(:sorted)    { mock('sorted') }
  let(:names)     { [ :id, :age, :name ] }
  let(:evaluator) { mock('evaluator') }

  fake(:relation)

  before do
    pending 'Relation#order is not implemented yet'
    names.each { |name| evaluator.should_receive(name).and_return(name) }
  end

  it { should be_instance_of(described_class) }

  its(:relation) { should be(sorted) }
  its(:header)   { should be(object.header) }
end
