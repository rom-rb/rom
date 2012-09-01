require 'spec_helper'

describe DataMapper::Mapper::Attribute::Mapper, '#load' do
  subject { attribute.load(tuple) }

  let(:attribute) { described_class.new(:title, :type => model) }
  let(:mapper)    { mock('mapper') }
  let(:model)     { mock_model(:TestModel) }
  let(:tuple)     { {} }
  let(:value)     { mock('loaded_object') }

  before do
    DataMapper.should_receive(:[]).with(model).and_return(mapper)
    attribute.finalize
    mapper.should_receive(:load).with(tuple).and_return(value)
  end

  it { should be(value) }
end
