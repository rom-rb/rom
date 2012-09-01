require 'spec_helper'

describe DataMapper::Mapper, '.map' do
  let(:name)    { :title }
  let(:options) { { :to => :book_title } }

  it "adds a new attribute to attribute set" do
    described_class.attributes.should_receive(:add).with(name, options)
    described_class.map(name, options)
  end
end
