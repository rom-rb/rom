require 'spec_helper'

describe Relation::Mapper, '.relationships' do
  it "returns relationship set" do
    described_class.relationships.should be_instance_of(described_class::RelationshipSet)
  end
end
