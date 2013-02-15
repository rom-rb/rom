require 'spec_helper'

describe Finalizer::RelationshipMappersFinalizer, '#run' do
  subject { object.run }

  let(:object) { described_class.new(DM_ENV) }

  let(:id)      { mock_attribute(:id,   Integer, :key => true) }
  let(:name)    { mock_attribute(:name, String) }

  let(:user_id) { mock_attribute(:user_id, Integer, :key => true) }
  let(:street)  { mock_attribute(:street, String) }

  let(:user_model)         { mock_model(:User) }
  let(:user_attributes)    { [ id, name ] }
  let(:user_mapper)        { mock_mapper(user_model, user_attributes) }

  let(:address_model)      { mock_model(:Address) }
  let(:address_attributes) { [ id, user_id, street ] }
  let(:address_mapper)     { mock_mapper(address_model, address_attributes) }

  let(:relationship) { Relationship::Builder::Has.build(user_mapper, 1, :address, address_model) }
  let!(:mappers)     { [ user_mapper, address_mapper ] }

  let(:mapper) { object.mapper_registry[user_model, relationship] }

  before do
    user_mapper.relationships << relationship
    Finalizer::BaseRelationMappersFinalizer.call(DM_ENV)
    subject
  end

  it { should be(object) }

  it "registers relationship mapper" do
    mapper.should be_kind_of(Relation::Mapper)
  end

  it "finalizes relationship mapper attributes" do
    mapper.attributes[:address].mapper.should be_instance_of(object.mapper_registry[address_model].class)
  end
end
