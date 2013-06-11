require 'spec_helper'

describe Graph::Node, '#take' do
  subject { object.take(1) }

  let(:object)    { Graph::Node.new(name, relation) }
  let(:name)      { :users }
  let(:relation)  { mock_relation('users', header, tuples).sort_by { |r| [ r.id.asc ] } }
  let(:header)    { [ [ :id, Integer ] ] }
  let(:tuples)    { [ [ 1 ], [ 2 ] ] }

  let(:expected_object)   { Graph::Node.new(name, expected_relation) }
  let(:expected_relation) { relation.take(1) }

  it { should eq(expected_object) }
end
