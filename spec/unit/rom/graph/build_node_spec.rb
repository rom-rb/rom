require 'spec_helper'

describe Graph, '#build_node' do
  subject { object.build_node(name, relation, aliases) }

  let(:object) { described_class.new }

  let(:name)     { 'users' }
  let(:aliases)  { mock('aliases') }

  let(:relation) { fake(:name => name) { Axiom::Relation } }

  context "when no node with the same name is included" do
    it "builds new node" do
      expect(subject).to be_instance_of(Graph::Node)
    end
  end

  context "when a node with the same name is included" do
    let(:other_node) { object.build_node(name, relation, aliases) }

    before do
      object.add_node(other_node)
    end

    it "returns the already included node" do
      subject.should be(other_node)
    end
  end
end
