require 'spec_helper'

describe Finalizer, '#mapper_builder' do
  subject { object.mapper_builder }

  context 'with no mapper_builder passed into #initialize' do
    let(:object)  { described_class.new(ROM_ENV) }

    it { should == Relation::Mapper::Builder }
  end

  context 'with mapper_builder passed into #initialize' do
    let(:object)            { described_class.new(ROM_ENV, connector_builder, mapper_builder) }
    let(:mappers)           { mock('Mapper::Registry') }
    let(:connector_builder) { mock('ConnectorBuilder') }
    let(:mapper_builder)    { mock('Relation::Mapper::Builder') }

    it { should == mapper_builder }
  end
end
