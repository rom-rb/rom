require 'spec_helper'

describe Graph, '#edge_for' do
  subject { object.edge_for(name) }

  let(:object) { described_class.new }

  let(:edge)           { object.build_edge(name, left, right) }

  let(:name)           { mock('left_right', :to_sym => :left_right, :relationship => relationship) }
  let(:relationship)   { mock('relationship', :join_definition => mock) }

  let(:left)           { mock('left',  :header => left_header, :relation => left_relation) }
  let(:left_header)    { mock('left_header', :join => {}, :aliases => {}) }
  let(:left_relation)  { mock('left_relation', :rename => mock) }

  let(:right)          { mock('right', :header => right_header, :relation => right_relation) }
  let(:right_header)   { mock('right_header', :join => {}, :aliases => {}) }
  let(:right_relation) { mock('right_relation', :rename => mock) }

  before { object.add_edge(edge) }

  it { should be(edge) }
end
