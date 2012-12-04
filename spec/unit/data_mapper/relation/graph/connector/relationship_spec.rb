require 'spec_helper'

describe Relation::Graph::Connector, '#relationship' do
  subject { object.relationship }

  let(:object) { described_class.new(node, relationship, relations) }

  let(:node)         { mock('relation_node', :name => mock) }
  let(:relationship) { mock('relationship', :name => mock) }
  let(:relations)    { mock('relations') }

  it { should equal(relationship) }
end
