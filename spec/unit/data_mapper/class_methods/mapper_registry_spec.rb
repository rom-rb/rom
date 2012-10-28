require 'spec_helper'

describe DataMapper, '.mapper_registry' do
  subject { DataMapper.mapper_registry }

  let(:mapper_registry) { mock('mapper_registry') }

  before { Mapper.should_receive(:mapper_registry).and_return(mapper_registry) }

  it { should be(mapper_registry) }
end
