require 'spec_helper'

describe Mapper::Builder, '.call' do
  subject { described_class.call(connector) }

  let(:connector)     { mock('connector') }
  let(:builder)       { mock('builder', :mapper => mapper_class) }
  let(:mapper_class)  { mock('mapper_class') }

  it "builds a mapper class and returns it" do
    described_class.should_receive(:new).with(connector).
      and_return(builder)

    subject.should be(mapper_class)
  end
end
