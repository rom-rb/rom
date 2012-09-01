require 'spec_helper'

describe DataMapper::Mapper::AttributeSet, '#add' do
  let(:attributes) { described_class.new }
  let(:name)       { :title }
  let(:options)    { { :type => String } }
  let(:attribute)  { mock('attribute') }

  it "adds a new attribute" do
    DataMapper::Mapper::Attribute.should_receive(:build).with(name, options).
      and_return(attribute)

    attributes.add(name, options).should be(attributes)

    attributes[name].should be(attribute)
  end
end
