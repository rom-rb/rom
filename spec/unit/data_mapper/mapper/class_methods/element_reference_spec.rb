require 'spec_helper'

describe Mapper, '.[]' do
  let(:model)           { mock_model(:TestModel) }
  let(:mapper)          { mock_mapper(model) }
  let(:mapper_instance) { mapper.new(relation) }
  let(:relation)        { mock('relation') }
  let(:other_relation)  { mock('other_relation') }

  before do
    described_class.registry << mapper_instance
    described_class.registry << mock_mapper(mock_model(:OtherModel)).new(other_relation)
  end

  it "returns correct mapper instance" do
    described_class[TestModel].should be(mapper_instance)
  end
end
