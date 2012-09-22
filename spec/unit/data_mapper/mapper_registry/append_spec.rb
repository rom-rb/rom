require 'spec_helper'

describe DataMapper::MapperRegistry, '#<<' do
  let(:model)    { mock('model') }
  let(:mapper)   { mock_mapper(model).new }
  let(:registry) { described_class.new }

  it "adds a new mapper to the registry" do
    registry << mapper
    registry[model].should be(mapper)
  end
end
