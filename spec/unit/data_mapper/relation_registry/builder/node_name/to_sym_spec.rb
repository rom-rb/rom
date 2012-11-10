require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#to_sym' do
  subject { object.to_sym }

  context "without relationship" do
    let(:object) { described_class.new('foo', 'bar') }

    it { should eql(:foo_X_bar) }
  end

  context "with relationship" do
    let(:object) { described_class.new('foo', 'bar', relationship) }

    context "without operation" do
      let(:relationship) { mock('relationship', :name => :extra_bar, :operation => nil) }

      it { should eql(:foo_X_bar) }
    end

    context "with operation" do
      let(:relationship) { mock('relationship', :name => :extra_bar, :operation => Proc.new{}) }

      it { should eql(:foo_X_extra_bar) }
    end
  end
end
