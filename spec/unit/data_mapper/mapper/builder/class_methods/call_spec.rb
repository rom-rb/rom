require 'spec_helper'

describe Mapper::Builder, '.call' do
  subject { described_class.call(connector, source_mapper) }

  let(:connector)     { mock('connector') }
  let(:source_mapper) { mock('source_mapper') }
  let(:builder)       { mock('builder', :mapper => mapper_class) }
  let(:mapper_class)  { mock('mapper_class') }

  it "builds a mapper class and returns it" do
    described_class.should_receive(:new).with(connector, source_mapper).
      and_return(builder)

    subject.should be(mapper_class)
  end
end
