require 'spec_helper'

describe Graph, '#add_node' do
  subject { object.new_node(name) }

  let(:object) { described_class.new }
  let(:name)   { 'node 1' }
  let(:node)   { mock('node', :name => name) }

  before do
    Graph::Node.should_receive(:new).with(name).and_return(node)
  end

  it { should be_instance_of(Graph) }

  its(:nodes) { should include(node) }
end
