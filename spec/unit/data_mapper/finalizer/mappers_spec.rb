require 'spec_helper'

describe Finalizer, '#mappers' do
  subject { object.mappers }

  context 'with no mappers passed into #initialize' do
    let(:object)  { described_class.new }

    it { should == Mapper::Relation.descendants }
  end

  context 'with mappers passed into #initialize' do
    let(:object)  { described_class.new(mappers) }
    let(:mappers) { mock('MapperRegistry')       }

    it { should == mappers }
  end
end
