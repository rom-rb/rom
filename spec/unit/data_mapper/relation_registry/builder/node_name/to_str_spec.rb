require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#to_str' do
  subject { object.to_str }

  let(:object) { described_class.new('foo', 'bar') }

  it { should eql('foo_X_bar') }
end
