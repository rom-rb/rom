require 'spec_helper'

describe Relation::Graph::Edge, '#connects?' do
  subject { object.connects?(node) }

  let(:object) { described_class.new(name, source, target) }
  let(:node1)  { Relation::Graph::Node.new('node1', relation) }
  let(:node2)  { Relation::Graph::Node.new('node2', relation) }
  let(:other)  { Relation::Graph::Node.new('other', relation) }

  let(:name)         { mock('edge', :relationship => relationship, :to_sym => :orders) }
  let(:relationship) { mock('relationship', :join_definition => mock) }
  let(:relation)     { mock_relation('relation') }

  context "when source node is connected" do
    let(:node)   { node1 }
    let(:source) { node  }
    let(:target) { other }

    it { should be(true) }
  end

  context "when target node is connected" do
    let(:node)   { node1 }
    let(:source) { other }
    let(:target) { node  }

    it { should be(true) }
  end

  context "when none of the nodes is connected" do
    let(:node)   { node1 }
    let(:source) { other }
    let(:target) { other }

    it { should be(false) }
  end
end
