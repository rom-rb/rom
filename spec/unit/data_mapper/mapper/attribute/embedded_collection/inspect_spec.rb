require 'spec_helper'

describe DataMapper::Mapper::Attribute::EmbeddedCollection, '#inspect' do
  subject { attribute.inspect }

  let(:attribute) { described_class.new(:books, :type => model, :collection => true) }
  let(:mapper)    { mock('mapper', :to_s => "TestModelMapper") }
  let(:model)     { mock_model(:TestModel) }

  before do
    DataMapper.should_receive(:[]).with(model).and_return(mapper)
    attribute.finalize
  end

  it { should eql("<#DataMapper::Mapper::Attribute::EmbeddedCollection @name=books @mapper=TestModelMapper>") }
end
