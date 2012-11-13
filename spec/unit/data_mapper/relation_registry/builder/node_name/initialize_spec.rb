require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#initialize' do
  subject { object.new(left, right, relationship) }

  let(:object)       { described_class }
  let(:left)         { :foo }
  let(:right)        { :bar }
  let(:relationship) { mock('relationship', :name => :funky_bar) }

  context "with valid arguments" do
    its(:left)         { should be(left) }
    its(:right)        { should be(right) }
    its(:relationship) { should be(relationship) }
  end

  context "when left is missing" do
    let(:left) { nil }

    specify do
      expect { subject }.to raise_error(ArgumentError, "+left+ and +right+ must be defined")
    end
  end

  context "when right is missing" do
    let(:right) { nil }

    specify do
      expect { subject }.to raise_error(ArgumentError, "+left+ and +right+ must be defined")
    end
  end

  context 'when relationship is missing' do
    let(:relationship) { nil }

    specify do
      expect { subject }.to_not raise_error(ArgumentError)
    end

    its(:relationship) { should be(relationship) }
  end
end
