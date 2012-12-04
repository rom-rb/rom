require 'spec_helper'

describe Relation::Mapper, '#each' do
  let(:object)   { Class.new(described_class).model(model).new(relation) }
  let(:model)    { mock_model(:User) }
  let(:relation) { mock('relation') }

  context "without a block" do
    subject { object.each }

    it { should be_instance_of(Enumerator) }
  end

  context "with a block" do
    subject { object.each(&block) }

    let(:block) { Proc.new {} }
    let(:tuple) { {} }

    it "iterates over relation tuples and loads them" do
      relation.should_receive(:each).with(&block).and_yield(tuple)
      model.should_receive(:new).with(tuple)
      subject
    end
  end
end
