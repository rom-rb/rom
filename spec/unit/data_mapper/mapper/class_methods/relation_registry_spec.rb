require 'spec_helper'

describe DataMapper::Mapper, '.relation_registry' do
  it "returns mapper registry instance" do
    described_class.relation_registry.should be_instance_of(described_class::RelationRegistry)
  end
end
