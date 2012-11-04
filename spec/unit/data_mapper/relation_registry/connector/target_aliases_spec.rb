require 'spec_helper'

describe RelationRegistry::Connector, '#target_aliases' do
  subject { object.target_aliases }

  let(:object) { described_class.new(name, node, relationship, relations) }

  let(:name)            { :user_X_address }
  let(:node)            { mock('relation_node') }
  let(:relationship)    { mock('relationship', :source_model => source_model, :target_model => target_model) }
  let(:source_model)    { mock_model(:User) }
  let(:target_model)    { mock_model(:Address) }
  let(:relations)       { mock('relations', :addresses => target_relation) }
  let(:target_relation) { mock('target_relation', :aliases => {}) }
  let(:source_mapper)   { mock_mapper(source_model) }
  let(:target_mapper)   { mock_mapper(target_model) }

  before { Mapper.mapper_registry << source_mapper << target_mapper }

  before { relations.should_receive(:[]).with(:addresses).and_return(target_relation) }

  it { should be(target_relation.aliases) }
end
