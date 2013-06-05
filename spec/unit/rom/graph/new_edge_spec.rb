require 'spec_helper'

describe Graph, '#new_edge' do
  subject { object.new_edge(name, left, right) }

  let(:object) { described_class.new }

  let(:name)           { mock('users', :to_sym => :users, :relationship => relationship) }
  let(:relationship)   { mock('relationship', :join_definition => mock) }

  let(:left)           { mock('left',  :header => left_header, :relation => left_relation) }
  let(:left_header)    { mock('left_header', :join => {}, :aliases => {}) }
  let(:left_relation)  { mock('left_relation', :rename => mock) }

  let(:right)          { mock('right', :header => right_header, :relation => right_relation) }
  let(:right_header)   { mock('right_header', :join => {}, :aliases => {}) }
  let(:right_relation) { mock('right_relation', :rename => mock) }

  it { should be(object) }

  it "adds a new edge" do
    subject.edge_for(name).should be_instance_of(Graph::Edge)
  end
end
