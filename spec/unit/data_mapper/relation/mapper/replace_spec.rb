require 'spec_helper'

describe Relation::Mapper, '#replace' do
  subject { object.replace(other) }

  let(:object)    { mapper.new(DM_ENV, node) }
  let(:mapper)    { mock_mapper(model, [ id ]) }
  let(:model)     { mock_model(:User) }
  let(:id)        { mock_attribute(:id, Integer) }
  let(:node)      { Relation::Graph::Node.new(node_name, relation) }
  let(:node_name) { :users }
  let(:relation)  { mock_relation('users', header, tuples) }
  let(:header)    { [ [ :id, Integer ], [ :name, String ] ] }
  let(:tuples)    { [ [ 1, 'John' ], [ 2, 'Jane' ] ] }
  let(:other)     { model.new(:id => 1, :name => 'Alice') }

  let(:expected_object) { mapper.new(DM_ENV, expected_node) }
  let(:expected_node)   { node.replace(object.dump(other)) }

  it { should eq(expected_object) }
end
