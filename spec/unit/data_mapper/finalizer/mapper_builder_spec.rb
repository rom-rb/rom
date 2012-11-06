require 'spec_helper'

describe Finalizer, '#mapper_builder' do
  subject { object.mapper_builder }

  context 'with no mapper_builder passed into #initialize' do
    let(:object)  { described_class.new }

    it { should == Mapper::Builder }
  end

  context 'with mapper_builder passed into #initialize' do
    let(:object)         { described_class.new(mappers, edge_builder, mapper_builder) }
    let(:mappers)        { mock('MapperRegistry') }
    let(:edge_builder)   { mock('EdgeBuilder')    }
    let(:mapper_builder) { mock('MapperBuilder')  }

    it { should == mapper_builder }
  end
end
