require 'spec_helper'

describe RelationRegistry::Connector, '#source_model' do
  subject { object.source_model }

  let(:object) { described_class.new(node, relationship, relations) }

  let(:node)         { mock('relation_node', :name => name) }
  let(:name)         { :users_X_addresses }
  let(:relationship) { mock('relationship', :source_model => source_model, :target_model => target_model) }
  let(:source_model) { mock_model(:User) }
  let(:target_model) { mock_model(:Address) }
  let(:relations)    { mock('relations') }

  it { should be(source_model) }
end
