require 'spec_helper'

describe Finalizer, '#edge_builder' do
  subject { object.edge_builder }

  context 'with no edge_builder passed into #initialize' do
    let(:object)  { described_class.new }

    it { should == RelationRegistry::Builder }
  end

  context 'with edge_builder passed into #initialize' do
    let(:object)       { described_class.new(mappers, edge_builder) }
    let(:mappers)      { mock('MapperRegistry') }
    let(:edge_builder) { mock('EdgeBuilder')    }

    it { should == edge_builder }
  end
end
