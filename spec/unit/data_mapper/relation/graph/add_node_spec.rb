require 'spec_helper'

describe Relation::Graph, '#add_node' do
  subject { object.add_node(node) }

  let(:object) { described_class.new }
  let(:node)   { mock('node', :name => 'node 1') }

  it { should be_instance_of(Relation::Graph) }

  its(:nodes) { should include(node) }
end
