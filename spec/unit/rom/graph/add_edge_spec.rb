require 'spec_helper'

describe Graph, '#add_edge' do
  subject { object.add_edge(edge) }

  let(:object) { described_class.new }

  let(:node1) {
    fake(:node, :name => 'node 1') { Graph::Node }
  }

  let(:node2) {
    fake(:node, :name => 'node 2') { Graph::Node }
  }

  let(:edge) {
    fake(:edge, :name => 'edge 1', :source_node => node1, :target_node => node2) { Graph::Edge }
  }

  it { should be_instance_of(Graph) }

  its(:edges) { should include(edge) }
end
