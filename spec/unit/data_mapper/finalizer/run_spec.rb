require 'spec_helper'

describe Finalizer, '#run' do
  subject { object.run }

  let(:object)  { described_class.new(mappers) }
  let(:mappers) { [ mock('mapper1'), mock('mapper2') ] }


  it 'finalizes base mappers and then relationship mappers' do
    Finalizer::BaseRelationMappersFinalizer.should_receive(:call).with(
      mappers, object.connector_builder, object.mapper_builder
    )

    Finalizer::RelationshipMappersFinalizer.should_receive(:call).with(
      mappers, object.connector_builder, object.mapper_builder
    )

    subject.should be(object)
  end
end
