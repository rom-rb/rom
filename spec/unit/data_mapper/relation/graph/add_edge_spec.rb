require 'spec_helper'

describe Relation::Graph, '#add_edge' do
  subject { object.add_edge(edge) }

  let(:object) { described_class.new }
  let(:node1)  { mock('node_1', :name => 'node 1') }
  let(:node2)  { mock('node_2', :name => 'node 2') }
  let(:edge)   { mock('edge', :name => 'edge 1', :left => node1, :right => node2) }

  it { should be_instance_of(Relation::Graph) }

  its(:edges) { should include(edge) }
end
