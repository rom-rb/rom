require 'spec_helper'

describe Finalizer::BaseRelationMappersFinalizer, '#run' do
  subject { object.run }

  let(:object)  { described_class.new(mappers) }

  let(:mappers) { [ user_mapper, address_mapper ] }

  let(:user_mapper)        { mock_mapper(user_model, user_attributes, [ relationship ]) }
  let(:user_model)         { mock_model(:User) }
  let(:user_attributes)    { [ users_id, users_name ] }
  let(:users_id)           { mock_attribute(:id,   Integer, :key => true) }
  let(:users_name)         { mock_attribute(:name, String) }

  let(:address_mapper)     { mock_mapper(address_model, address_attributes) }
  let(:address_model)      { mock_model(:Address) }
  let(:address_attributes) { [ addresses_id, addresses_user_id, addresses_street ] }
  let(:addresses_id)       { mock_attribute(:id,      Integer, :key => true) }
  let(:addresses_user_id)  { mock_attribute(:user_id, Integer, :key => true) }
  let(:addresses_street)   { mock_attribute(:street,  String) }

  let(:relationship) { Relationship::OneToOne.new(:address, user_model, address_model) }

  it_should_behave_like 'a command method'

  it "adds relation node for user mapper" do
    user_mapper.relations[:users].should be_kind_of(RelationRegistry::RelationNode)
  end

  it "adds relation node for address mapper" do
    address_mapper.relations[:addresses].should be_kind_of(RelationRegistry::RelationNode)
  end
end
