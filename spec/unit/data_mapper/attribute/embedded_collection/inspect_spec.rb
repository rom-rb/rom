require 'spec_helper'

describe Attribute::EmbeddedCollection, '#inspect' do
  subject { attribute.inspect }

  let(:attribute) { described_class.new(:books, :type => model, :collection => true) }
  let(:mapper)    { mock('mapper', :to_s => "TestModelMapper") }
  let(:model)     { mock_model(:TestModel) }

  before do
    attribute.finalize(model => mapper)
  end

  it { should eql("#<DataMapper::Attribute::EmbeddedCollection @name=books @mapper=TestModelMapper>") }
end
