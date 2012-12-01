require 'spec_helper'

describe Finalizer, '#connector_builder' do
  subject { object.connector_builder }

  context 'with no connector_builder passed into #initialize' do
    let(:object)  { described_class.new }

    it { should == RelationRegistry::Connector::Builder }
  end

  context 'with connector_builder passed into #initialize' do
    let(:object)            { described_class.new(mappers, connector_builder) }
    let(:mappers)           { mock('MapperRegistry') }
    let(:connector_builder) { mock('ConnectorBuilder')    }

    it { should == connector_builder }
  end
end
