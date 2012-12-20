require 'spec_helper'

describe DataMapper::Attribute::Primitive, '#inspect' do
  subject { attribute.inspect }

  let(:attribute) { described_class.new(:title, :type => String) }

  it { should eql("<#DataMapper::Attribute::Primitive @name=title @type=String @field=title @key=false>")}
end
