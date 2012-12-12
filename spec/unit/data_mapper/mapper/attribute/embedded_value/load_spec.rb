require 'spec_helper'

describe DataMapper::Mapper::Attribute::EmbeddedValue, '#load' do
  subject { attribute.load(tuple) }

  let(:attribute) { described_class.new(:title, :type => model) }
  let(:mapper)    { mock('mapper') }
  let(:model)     { mock_model(:TestModel) }
  let(:tuple)     { { :title => {} } }
  let(:value)     { mock('loaded_object') }

  before do
    attribute.finalize(model => mapper)
    mapper.should_receive(:load).with({}).and_return(value)
  end

  it { should be(value) }
end
