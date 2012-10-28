require 'spec_helper'

describe Graph::Edge, '#connects?' do
  subject { object.connects?(node) }

  let(:object) { described_class.new('edge', left, right) }
  let(:node1)  { Graph::Node.new('node1') }
  let(:node2)  { Graph::Node.new('node2') }
  let(:other)  { Graph::Node.new('other') }

  context "when left node is connected" do
    let(:node)  { node1 }
    let(:left)  { node  }
    let(:right) { other }

    it { should be(true) }
  end

  context "when right node is connected" do
    let(:node)  { node1 }
    let(:left)  { other }
    let(:right) { node  }

    it { should be(true) }
  end

  context "when none of the nodes is connected" do
    let(:node)  { node1 }
    let(:left)  { other }
    let(:right) { other }

    it { should be(false) }
  end
end
