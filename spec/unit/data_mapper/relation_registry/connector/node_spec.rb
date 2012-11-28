require 'spec_helper'

describe RelationRegistry::Connector, '#node' do
  subject { object.node }

  let(:object) { described_class.new(node, relationship, relations) }

  let(:node)         { mock('relation_node', :name => name) }
  let(:name)         { :users_X_addresses }
  let(:relationship) { mock('relationship') }
  let(:relations)    { mock('relations') }

  it { should equal(node) }
end
