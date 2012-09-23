require 'spec_helper'

describe DataMapper::Mapper::Attribute::Primitive, '#inspect' do
  subject { attribute.inspect }

  let(:attribute) { described_class.new(:title, :type => String) }

  it { should eql("<#DataMapper::Mapper::Attribute::Primitive @name=title @type=String @field=title @key=false>")}
end
