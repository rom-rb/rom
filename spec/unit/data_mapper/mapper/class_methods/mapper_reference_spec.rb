require 'spec_helper'

describe DataMapper::Mapper, '.[]' do
  let(:model)           { mock_model(:TestModel) }
  let(:mapper)          { mock_mapper(model) }
  let(:mapper_instance) { mapper.new }

  before do
    described_class.mapper_registry << mapper_instance
    described_class.mapper_registry << mock_mapper(mock_model(:OtherModel)).new
  end

  it "returns correct mapper instance" do
    described_class[TestModel].should be(mapper_instance)
  end
end
