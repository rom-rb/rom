require 'spec_helper'

describe Graph, '#edges_for' do
  subject { object.edges_for(node) }

  let(:object) { described_class.new }
  let(:node)   { mock('node') }
  let(:edge)   { mock('edge') }

  before do
    object.add_edge(edge)
  end

  context "when edge connects the node" do
    before do
      edge.should_receive(:connects?).with(node).and_return(true)
    end

    it { should include(edge) }
  end

  context "when edge doesn't connect the node" do
    before do
      edge.should_receive(:connects?).with(node).and_return(false)
    end

    it { should_not include(edge) }
  end
end
