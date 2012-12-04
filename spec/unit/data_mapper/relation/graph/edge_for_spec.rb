require 'spec_helper'

describe Relation::Graph, '#edge_for' do
  subject { object.edge_for(name) }

  let(:object) { described_class.new(TEST_ENGINE) }

  let(:edge)           { object.build_edge(name, left, right) }

  let(:name)           { mock('left_right', :to_sym => :left_right, :relationship => relationship) }
  let(:relationship)   { mock('relationship', :join_definition => mock) }

  let(:left)           { mock('left',  :aliases => left_aliases, :relation => left_relation) }
  let(:left_aliases)   { mock('left_aliases', :join => {}, :to_hash => {}) }
  let(:left_relation)  { mock('left_relation', :rename => mock) }

  let(:right)          { mock('right', :aliases => right_aliases, :relation => right_relation) }
  let(:right_aliases)  { mock('right_aliases', :join => {}, :to_hash => {}) }
  let(:right_relation) { mock('right_relation', :rename => mock) }

  before { object.add_edge(edge) }

  it { should be(edge) }
end
