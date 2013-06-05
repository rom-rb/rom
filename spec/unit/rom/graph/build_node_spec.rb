require 'spec_helper'

describe Graph, '#build_node' do
  subject { object.build_node(name, relation, aliases) }

  let(:object) { described_class.new }

  let(:name)     { 'users' }
  let(:relation) { mock_relation(name) }
  let(:aliases)  { mock('aliases') }

  context "when no node with the same name is included" do
    it "delegates to Graph::Edge.new" do
      Graph::Node.should_receive(:new).with(name, relation, aliases)
      subject
    end
  end

  context "when a node with the same name is included" do
    let(:other_node) { object.build_node(name, relation, aliases) }

    before do
      object.add_node(other_node)
    end

    it "returns the already included node" do
      object.should_receive(:node_for).with(relation).and_return(other_node)
      subject.should be(other_node)
    end

    it "does not delegate to Graph::Node.new" do
      Graph::Node.should_not_receive(:new).with(name, relation, aliases)
      subject
    end
  end
end
