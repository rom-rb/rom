require 'spec_helper'

describe Relation::Mapper, '#first' do
  let(:object)    { mapper.new(DM_ENV, node) }
  let(:mapper)    { mock_mapper(model, [ id ]) }
  let(:model)     { mock_model(:User) }
  let(:id)        { mock_attribute(:id, Integer) }
  let(:node)      { Relation::Graph::Node.new(node_name, relation) }
  let(:node_name) { :users }
  let(:relation)  { mock_relation('users', header, tuples).sort_by { |r| [ r.id.asc ] } }
  let(:header)    { [ [ :id, Integer ] ] }
  let(:tuples)    { [ [ 1 ], [ 2 ], [ 3 ] ] }

  let(:expected_object)   { mapper.new(DM_ENV, expected_node) }
  let(:expected_node)     { Relation::Graph::Node.new(node_name, expected_relation) }

  context "with no limit" do
    subject { object.first }

    let(:expected_relation) { relation.first }

    it { should eq(expected_object) }
  end

  context "with a limit" do
    subject { object.first(2) }

    let(:expected_relation) { relation.first(2) }

    it { should eq(expected_object) }
  end
end
