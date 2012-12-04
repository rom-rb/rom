require 'spec_helper'

describe Finalizer, '#connector_builder' do
  subject { object.connector_builder }

  context 'with no connector_builder passed into #initialize' do
    let(:object)  { described_class.new }

    it { should == Relation::Graph::Connector::Builder }
  end

  context 'with connector_builder passed into #initialize' do
    let(:object)            { described_class.new(mappers, connector_builder) }
    let(:mappers)           { mock('Mapper::Registry') }
    let(:connector_builder) { mock('Relation::Graph::Connector::Builder')    }

    it { should == connector_builder }
  end
end
