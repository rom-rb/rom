require 'spec_helper'

describe RelationRegistry::Connector, '#name' do
  subject { object.name }

  let(:object) { described_class.new(node, relationship, relations) }

  let(:name)         { :users_X_addresses }
  let(:node)         { mock('relation_node', :name => name) }
  let(:relationship) { mock('relationship') }
  let(:relations)    { mock('relations') }

  it { should equal(name) }
end
