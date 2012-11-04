require 'spec_helper'

describe RelationRegistry::Connector, '#collection_target?' do
  subject { object.collection_target? }

  let(:object) { described_class.new(name, node, relationship, relations) }

  let(:name)         { :user_X_address }
  let(:node)         { mock('relation_node') }
  let(:source_model) { mock_model(:User) }
  let(:target_model) { mock_model(:Address) }
  let(:relations)    { mock('relations') }

  context "when relationship has collection target" do
    let(:relationship) { mock('relationship', :collection_target? => true) }

    it { should be(true) }
  end

  context "when relationship doesn't have collection target" do
    let(:relationship) { mock('relationship', :collection_target? => false) }

    it { should be(false) }
  end
end
