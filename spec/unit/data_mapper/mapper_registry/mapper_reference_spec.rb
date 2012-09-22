require 'spec_helper'

describe DataMapper::MapperRegistry, '#[]' do
  subject { registry[model] }

  let(:model)    { mock('model') }
  let(:mapper)   { mock_mapper(model).new }
  let(:registry) { described_class.new(model => mapper) }

  it { should be(mapper) }
end
