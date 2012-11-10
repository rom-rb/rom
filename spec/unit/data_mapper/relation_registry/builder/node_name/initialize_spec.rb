require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#initialize' do
  context "with 2 args" do
    subject { described_class.new(:foo, :bar) }

    it "sets left" do
      subject.left.should be(:foo)
    end

    it "sets right" do
      subject.right.should be(:bar)
    end

    it "doesn't set relationship" do
      subject.relationship.should be_nil
    end
  end

  context "with 3 args" do
    subject { described_class.new(:foo, :bar, relationship) }

    let(:relationship) { mock('relationship', :name => :funky_bar) }

    it "sets relationship" do
      subject.relationship.should be(relationship)
    end
  end

  context "when left is missing" do
    subject { described_class.new(nil, :bar) }

    specify do
      expect { subject }.to raise_error(ArgumentError, "+left+ and +right+ must be defined")
    end
  end

  context "when right is missing" do
    subject { described_class.new(:foo, nil) }

    specify do
      expect { subject }.to raise_error(ArgumentError, "+left+ and +right+ must be defined")
    end
  end
end
