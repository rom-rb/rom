require 'spec_helper'

describe DataMapper, '.build' do
  subject { DataMapper.build(model, repository, &block) }

  let(:model)        { mock('model') }
  let(:repository)   { mock('repository') }
  let(:block)        { Proc.new {} }
  let(:mapper_class) { mock('mapper_class') }

  before do
    Mapper::Builder.should_receive(:create).with(model, repository, &block).
      and_return(mapper_class)
  end

  it { should be(mapper_class) }
end
