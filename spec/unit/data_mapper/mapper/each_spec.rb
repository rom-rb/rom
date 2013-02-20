require 'spec_helper'

describe Mapper, '#each' do
  let(:object)     { described_class.model(model).new(collection) }
  let(:model)      { mock_model(:User) }
  let(:collection) { mock('collection') }

  context "without a block" do
    subject { object.each }

    it { should be_instance_of(Enumerator) }
  end

  context "with a block" do
    subject { object.each(&block) }

    let(:block) { Proc.new {} }
    let(:tuple) { {} }

    it "iterates over relation tuples and loads them" do
      collection.should_receive(:each).with(&block).and_yield(tuple)
      model.should_receive(:new).with(tuple)
      subject
    end
  end
end
