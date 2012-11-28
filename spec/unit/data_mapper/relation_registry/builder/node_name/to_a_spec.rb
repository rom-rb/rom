require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#to_a' do
  subject { object.to_a }

  let(:object) { described_class.new(left, right, relationship) }

  let(:left)         { :foo }
  let(:right)        { :bar }
  let(:relationship) { mock('relationship') }

  it { should eql([ left, right ]) }
end
