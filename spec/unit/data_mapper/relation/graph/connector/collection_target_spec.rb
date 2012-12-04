require 'spec_helper'

describe Relation::Graph::Connector, '#collection_target?' do
  subject { object.collection_target? }

  let(:object) { described_class.new(node, relationship, relations) }

  let(:node)         { mock('relation_node', :name => mock) }
  let(:relations)    { mock('relations') }

  context "when relationship has collection target" do
    let(:relationship) { mock('relationship', :collection_target? => true, :name => mock) }

    it { should be(true) }
  end

  context "when relationship doesn't have collection target" do
    let(:relationship) { mock('relationship', :collection_target? => false, :name => mock) }

    it { should be(false) }
  end
end
