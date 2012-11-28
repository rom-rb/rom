require 'spec_helper'

describe RelationRegistry::Connector, '#relationship' do
  subject { object.relationship }

  let(:object) { described_class.new(node, relationship, relations) }

  let(:node)         { mock('relation_node', :name => name) }
  let(:name)         { :users_X_addresses }
  let(:relationship) { mock('relationship') }
  let(:relations)    { mock('relations') }

  it { should equal(relationship) }
end
