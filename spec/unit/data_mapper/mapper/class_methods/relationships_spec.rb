require 'spec_helper'

describe DataMapper::Mapper, '.relationships' do
  it "returns relationship set" do
    described_class.relationships.should be_instance_of(described_class::RelationshipSet)
  end
end
