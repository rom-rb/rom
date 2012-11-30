require 'spec_helper'

describe RelationRegistry::Connector, '#relations' do
  subject { object.relations }

  let(:object) { described_class.new(node, relationship, relations) }

  let(:node)         { mock('relation_node', :name => mock) }
  let(:relationship) { mock('relationship', :name => mock) }
  let(:relations)    { mock('relations') }

  it { should equal(relations) }
end
