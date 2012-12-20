require 'spec_helper'

describe AttributeSet, '#<<' do
  let(:attributes) { described_class.new }
  let(:name)       { :title }
  let(:options)    { { :type => String } }
  let(:attribute)  { mock('attribute', :name => :title) }

  it "adds a new attribute" do
    attributes << attribute
    attributes[name].should be(attribute)
  end
end
