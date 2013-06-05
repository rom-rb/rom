require 'spec_helper'

describe Graph::Node, '#update' do
  subject { object.update(tuples) }

  let(:object)         { Graph::Node.new(name, relation) }
  let(:name)           { :users }
  let(:relation)       { mock_relation('users', header, initial_tuples) }
  let(:header)         { [ [ :id, Integer ], [ :name, String ] ] }
  let(:initial_tuples) { [ [ 1, 'John' ] ] }
  let(:tuples)         { [ [ 1, 'Jane' ] ] }

  let(:expected_object)   { Graph::Node.new(name, expected_relation) }
  let(:expected_relation) { relation.delete(tuples).insert(tuples) }

  it { should eq(expected_object) }
end
