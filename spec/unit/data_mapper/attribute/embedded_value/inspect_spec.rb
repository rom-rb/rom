require 'spec_helper'

describe Attribute::EmbeddedValue, '#inspect' do
  subject { attribute.inspect }

  let(:attribute) { described_class.new(:title, :type => model) }
  let(:mapper)    { mock('mapper', :to_s => 'TestModelMapper') }
  let(:model)     { mock_model(:TestModel) }
  let(:tuple)     { {} }
  let(:value)     { mock('loaded_object') }

  before do
    attribute.finalize(model => mapper)
  end

  it { should eql("#<Rom::Attribute::EmbeddedValue @name=title @mapper=TestModelMapper>")}
end
