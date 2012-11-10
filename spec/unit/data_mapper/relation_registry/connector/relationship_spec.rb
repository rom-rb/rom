require 'spec_helper'

describe RelationRegistry::Connector, '#relations' do
  subject { object.relations }

  let(:object) { described_class.new(name, node, relationship, relations) }

  let(:name)         { :users_X_addresses }
  let(:node)         { mock('relation_node', :name => name) }
  let(:relationship) { mock('relationship') }
  let(:relations)    { mock('relations') }

  it { should equal(relations) }
end
