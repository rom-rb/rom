require 'spec_helper'

describe DataMapper::Mapper::Builder::Class, '.copy_attributes' do
  let(:model)      { mock_model('TestModel') }
  let(:mapper)     { mock_mapper(model) }
  let(:attributes) { [] }
  let(:name)       { 'foo' }
  let(:attribute)  { mock('attribute', :name => name, :options => options) }

  before do
    attributes << attribute
  end

  context "with a primitive attribute" do
    let(:options) { { :primitive => String } }

    it "maps the primitive attribute" do
      mapper.should_receive(:map).with(name, String)
      described_class.copy_attributes(mapper, attributes)
    end
  end

  context "with a collection attribute" do
    let(:options) { { :member_type => String } }

    it "map the collection attribute" do
      mapper.should_receive(:map).with(name, String, :collection => true)
      described_class.copy_attributes(mapper, attributes)
    end
  end
end
