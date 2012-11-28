require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#to_sym' do
  subject { object.to_sym }

  let(:object) { described_class.new(left, right, relationship) }

  let(:left)         { :foo }
  let(:right)        { :bar }
  let(:relationship) { mock('relationship') }

  it { should eql(:foo_X_bar) }
end
