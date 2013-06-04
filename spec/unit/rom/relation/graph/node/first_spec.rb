require 'spec_helper'

describe Relation::Graph::Node, '#first' do
  let(:object)    { Relation::Graph::Node.new(name, relation) }
  let(:name)      { :users }
  let(:relation)  { mock_relation('users', header, tuples).sort_by { |r| [ r.id.asc ] } }
  let(:header)    { [ [ :id, Integer ] ] }
  let(:tuples)    { [ [ 1 ], [ 2 ] ] }

  let(:expected_object)   { Relation::Graph::Node.new(name, expected_relation) }
  let(:expected_relation) { relation.first(1) }

  context "with no limit" do
    subject { object.first }

    let(:expected_relation) { relation.first }

    it { should eq(expected_object) }
  end

  context "with a limit" do
    subject { object.first(1) }

    let(:expected_relation) { relation.first(1) }

    it { should eq(expected_object) }
  end
end
