require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#to_sym' do
  subject { object.to_sym }

  let(:object) { described_class.new(left, right, relationship) }
  let(:left)   { :foo }
  let(:right)  { :bar }

  context 'with no relationship given' do
    let(:relationship) { nil }

    it { should eql(:foo_X_bar) }
  end

  context 'with a given relationship' do
    let(:relationship) { mock('relationship', :name => name, :operation => operation) }
    let(:name)         { :funky_bar }

    context 'with no operation' do
      let(:operation) { nil }

      it { should eql(:foo_X_bar) }
    end

    context 'with an operation' do
      let(:operation) { Proc.new {} }

      it { should eql(:foo_X_funky_bar) }
    end
  end
end
