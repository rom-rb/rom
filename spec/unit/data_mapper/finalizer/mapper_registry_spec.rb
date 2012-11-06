require 'spec_helper'

describe Finalizer, '#mapper_registry' do
  subject { object.mapper_registry }

  let(:object)          { described_class.new }
  let(:mapper_registry) { mock('MapperRegistry') }

  it 'is initialized to Mapper.mapper_registry' do
    Mapper.should_receive(:mapper_registry).and_return(mapper_registry)
    subject.should be(mapper_registry)
  end
end

