require 'spec_helper'

describe Rom::Attribute::Primitive, '#inspect' do
  subject { attribute.inspect }

  let(:attribute) { described_class.new(:title, :type => String) }

  it { should eql("<#Rom::Attribute::Primitive @name=title @type=String @field=title @key=false>")}
end
