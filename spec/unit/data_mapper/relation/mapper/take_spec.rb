require 'spec_helper'

describe Relation::Mapper, '#take' do
  subject { object.take(1) }

  let(:object)    { mapper.new(ROM_ENV, node) }
  let(:mapper)    { mock_mapper(model, [ id ]) }
  let(:model)     { mock_model(:User) }
  let(:id)        { mock_attribute(:id, Integer) }
  let(:node)      { Relation::Graph::Node.new(node_name, relation) }
  let(:node_name) { :users }
  let(:relation)  { mock_relation('users', header, tuples).sort_by { |r| [ r.id.asc ] } }
  let(:header)    { [ [ :id, Integer ] ] }
  let(:tuples)    { [ [ 1 ], [ 2 ] ] }

  let(:expected_object)   { mapper.new(ROM_ENV, expected_node) }
  let(:expected_node)     { Relation::Graph::Node.new(node_name, expected_relation) }
  let(:expected_relation) { relation.take(1) }

  it { should eq(expected_object) }
end
