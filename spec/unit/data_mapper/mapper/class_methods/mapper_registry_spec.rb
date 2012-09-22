require 'spec_helper'

describe DataMapper::Mapper, '.mapper_registry' do
  it "returns mapper registry instance" do
    described_class.mapper_registry.should be_instance_of(DataMapper::MapperRegistry)
  end
end
