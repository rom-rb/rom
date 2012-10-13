require 'spec_helper'

describe Graph, '#new_edge' do
  subject { object.new_edge(name, node1, node2) }

  let(:object) { described_class.new }
  let(:name)   { 'edge' }
  let(:node1)  { mock('node_1', name: 'node 1') }
  let(:node2)  { mock('node_2', name: 'node 2') }
  let(:edge)   { mock('edge', name: name, left: node1, right: node2) }

  before do
    Graph::Edge.should_receive(:new).with(name, node1, node2).and_return(edge)
  end

  it { should be_instance_of(Graph) }

  its(:edges) { should include(edge) }
end
