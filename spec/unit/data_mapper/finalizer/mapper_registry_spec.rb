require 'spec_helper'

describe Finalizer, '#mapper_registry' do
  subject { object.mapper_registry }

  let(:object)          { described_class.new(DM_ENV) }
  let(:mapper_registry) { mock('Mapper::Registry') }

  it 'is initialized to Mapper.mapper_registry' do
    DM_ENV.should_receive(:registry).and_return(mapper_registry)
    subject.should be(mapper_registry)
  end
end
