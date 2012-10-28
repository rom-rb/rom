require 'spec_helper'

describe MapperRegistry, '#<<', :type => :unit do
  let(:model)    { mock_model('TestModel') }
  let(:relation) { mock('relation') }
  let(:mapper)   { mock_mapper(model).new(relation) }
  let(:registry) { described_class.new }

  it "adds a new mapper to the registry" do
    registry << mapper
    registry[model].should be(mapper)
  end
end
