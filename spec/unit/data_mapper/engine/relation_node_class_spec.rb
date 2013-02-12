require 'spec_helper'

describe Engine, '#relation_node_class' do
  subject { object.relation_node_class }

  let(:object) { described_class.new(uri) }
  let(:uri)    { 'something://somewhere/test' }

  it { should be(Relation::Graph::Node) }
end
