require 'spec_helper'

describe Graph, '#add_node' do
  subject { object.add_node(node) }

  let(:object) { described_class.new }
  let(:node)   { fake(:node, :name => 'node 1') { Graph::Node } }

  it { should be_instance_of(Graph) }

  its(:nodes) { should include(node) }
end
