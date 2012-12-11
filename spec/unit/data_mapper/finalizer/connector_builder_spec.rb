require 'spec_helper'

describe Finalizer, '#connector_builder' do
  subject { object.connector_builder }

  context 'with no connector_builder passed into #initialize' do
    let(:object)  { described_class.new(DM_ENV) }

    it { should == Relation::Graph::Connector::Builder }
  end

  context 'with connector_builder passed into #initialize' do
    let(:object)            { described_class.new(DM_ENV, connector_builder) }
    let(:mappers)           { mock('Mapper::Registry') }
    let(:connector_builder) { mock('Relation::Graph::Connector::Builder')    }

    it { should == connector_builder }
  end
end
