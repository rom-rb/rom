require 'spec_helper'

describe Finalizer::BaseRelationMappersFinalizer, '#run' do
  subject { object.run }

  let(:object) { described_class.new(mappers) }

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
  let(:mappers)      { [ user_mapper, address_mapper ] }

  before { user_mapper.relationships << relationship }

  it { should be(object) }

  it "adds relation node for user mapper" do
    user_mapper.relations[:users].should be_kind_of(RelationRegistry::RelationNode)
  end

  it "adds relation node for address mapper" do
    address_mapper.relations[:addresses].should be_kind_of(RelationRegistry::RelationNode)
  end

  it "exclude join keys from address aliases" do
    address_mapper.relations[:addresses].aliases.excluded.should include(:user_id)
  end
end
