require 'spec_helper'

describe Finalizer, '#mappers' do
  subject { object.mappers }

  context 'with no mappers passed into #initialize' do
    let(:object)  { described_class.new }

    it { should == Relation::Mapper.descendants }
  end

  context 'with mappers passed into #initialize' do
    let(:object)  { described_class.new(mappers) }
    let(:mappers) { mock('Mapper::Registry')       }

    it { should == mappers }
  end
end
