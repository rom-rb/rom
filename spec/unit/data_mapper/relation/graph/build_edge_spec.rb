require 'spec_helper'

describe Relation::Graph, '#build_edge' do
  subject { object.build_edge(name, left, right) }

  let(:object) { described_class.new(TEST_ENGINE) }

  let(:name)           { mock('users', :to_sym => :users, :relationship => relationship) }
  let(:relationship)   { mock('relationship', :join_definition => mock) }

  let(:left)           { mock('left',  :header => left_header, :relation => left_relation) }
  let(:left_header)    { mock('left_header', :join => {}, :aliases => {}) }
  let(:left_relation)  { mock('left_relation', :rename => mock) }

  let(:right)          { mock('right', :header => right_header, :relation => right_relation) }
  let(:right_header)   { mock('right_header', :join => {}, :aliases => {}) }
  let(:right_relation) { mock('right_relation', :rename => mock) }

  context "when no edge with the same name is included" do
    it "delegates to TEST_ENGINE.relation_edge_class.new" do
      TEST_ENGINE.relation_edge_class.should_receive(:new).with(name, left, right)
      subject
    end
  end

  context "when an edge with the same name is included" do
    let(:other_edge) { object.build_edge(name, left, right) }

    before do
      object.add_edge(other_edge)
    end

    it "returns the already included edge" do
      object.should_receive(:edge_for).with(name).and_return(other_edge)
      subject.should be(other_edge)
    end

    it "does not delegate to TEST_ENGINE.relation_edge_class.new" do
      TEST_ENGINE.relation_edge_class.should_not_receive(:new).with(name, left, right)
      subject
    end
  end
end
