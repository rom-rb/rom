require 'spec_helper'

describe RelationRegistry::RelationNode::VeritasRelation, '#each' do
  let(:object)   { described_class.new(:users, relation) }
  let(:relation) { mock('relation') }
  let(:block)    { Proc.new {} }

  context "with a block" do
    subject { object.each(&block) }

    it "passes the block to veritas relation" do
      relation.should_receive(:each).with(&block)
      subject
    end
  end

  context "without a block" do
    subject { object.each }

    it { should be_instance_of(Enumerator) }
  end
end
