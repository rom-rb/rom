require 'spec_helper'

describe Engine, '#relation_edge_class' do
  subject { object.relation_edge_class }

  let(:object) { described_class.new(uri) }
  let(:uri)    { 'something://somewhere/test' }

  it { should be(Relation::Graph::Edge) }
end
