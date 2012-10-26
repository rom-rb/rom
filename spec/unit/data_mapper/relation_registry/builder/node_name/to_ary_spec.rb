require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#to_ary' do
  subject { object.to_ary }

  let(:object) { described_class.new('foo', 'bar') }

  it { should == [ :foo, :bar ] }
end
