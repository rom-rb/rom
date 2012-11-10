require 'spec_helper'

describe RelationRegistry::Connector, '#target_model' do
  subject { object.target_model }

  let(:object) { described_class.new(name, node, relationship, relations) }

  let(:name)         { :users_X_addresses }
  let(:node)         { mock('relation_node', :name => name) }
  let(:relationship) { mock('relationship', :source_model => source_model, :target_model => target_model) }
  let(:source_model) { mock_model(:User) }
  let(:target_model) { mock_model(:Address) }
  let(:relations)    { mock('relations') }

  it { should be(target_model) }
end
