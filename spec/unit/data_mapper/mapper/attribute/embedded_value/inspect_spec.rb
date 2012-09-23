require 'spec_helper'

describe DataMapper::Mapper::Attribute::EmbeddedValue, '#inspect' do
  subject { attribute.inspect }

  let(:attribute) { described_class.new(:title, :type => model) }
  let(:mapper)    { mock('mapper', :to_s => 'TestModelMapper') }
  let(:model)     { mock_model(:TestModel) }
  let(:tuple)     { {} }
  let(:value)     { mock('loaded_object') }

  before do
    DataMapper.should_receive(:[]).with(model).and_return(mapper)
    attribute.finalize
  end

  it { should eql("<#DataMapper::Mapper::Attribute::EmbeddedValue @name=title @mapper=TestModelMapper>")}
end
