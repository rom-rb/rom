require 'spec_helper'

describe Relation::Graph, '#new_edge' do
  subject { object.new_edge(name, left, right) }

  let(:object) { described_class.new(TEST_ENGINE) }

  let(:name)           { mock('users', :to_sym => :users, :relationship => relationship) }
  let(:relationship)   { mock('relationship', :join_definition => mock) }

  let(:left)           { mock('left',  :aliases => left_aliases, :relation => left_relation) }
  let(:left_aliases)   { mock('left_aliases', :join => {}, :to_hash => {}) }
  let(:left_relation)  { mock('left_relation', :rename => mock) }

  let(:right)          { mock('right', :aliases => right_aliases, :relation => right_relation) }
  let(:right_aliases)  { mock('right_aliases', :join => {}, :to_hash => {}) }
  let(:right_relation) { mock('right_relation', :rename => mock) }

  it { should be(object) }

  it "adds a new edge" do
    subject.edge_for(name).should be_instance_of(TEST_ENGINE.relation_edge_class)
  end
end
