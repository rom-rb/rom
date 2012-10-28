require 'spec_helper'

describe DataMapper, '.generate_mapper_for' do
  subject { DataMapper.generate_mapper_for(model, repository, &block) }

  let(:model)        { mock('model') }
  let(:repository)   { mock('repository') }
  let(:block)        { Proc.new {} }
  let(:mapper_class) { mock('mapper_class') }

  before do
    Mapper::Builder::Class.should_receive(:create).with(model, repository, &block).
      and_return(mapper_class)
  end

  it { should be(mapper_class) }
end
