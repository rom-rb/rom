require 'spec_helper'

describe RelationRegistry::RelationConnector::Builder, '.call', :type => :unit do
  subject { described_class.call(mappers, relations, relationship) }

  let(:parent_relation) { mock_relation(:users) }
  let(:parent_model)    { mock_model('User') }
  let(:parent_mapper)   { mock_mapper(parent_model).new(parent_relation) }

  let(:child_relation) { mock_relation(:addresses) }
  let(:child_model)    { mock_model('Address') }
  let(:child_mapper)   { mock_mapper(child_model).new(child_relation) }

  let(:relationship) { mock_relationship(:address, :source_model => parent_model, :target_model => child_model) }

  let(:mappers) { { parent_model => parent_mapper, child_model => child_mapper } }

  let(:relations) { RelationRegistry.new << parent_relation << child_relation }

  it { should be_kind_of(RelationRegistry::RelationConnector) }

  it "sets connector name" do
    subject.name.should be(relationship.name)
  end

  it "connects left side relation" do
    subject.left.relation.should be(parent_relation)
  end

  it "connects right side relation" do
    subject.right.relation.should be(child_relation)
  end
end
