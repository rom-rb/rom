require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#to_a' do
  subject { object.to_a }

  let(:object) { described_class.new('foo', 'bar') }

  it { should == [ :foo, :bar ] }
end
