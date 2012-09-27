require 'spec_helper'

describe DataMapper::Mapper::Builder::Relationship, '#mapper_class' do
  subject { relationship.mapper_class }

  let(:relationship)  { described_class.new(source_mapper.new, options) }

  let(:source_model)  { mock_model("User") }
  let(:source_mapper) { mock_mapper(source_model).map(:id, Integer) }
  let(:target_model)  { mock_model("Group") }

  let(:options)       {
    OpenStruct.new(
      :name         => :group,
      :target_model => target_model,
      :source_key   => :id,
      :target_key   => :user_id,
      :aliases      => { :id => :user_id }
    )
  }

  its(:name) { should eql("UserGroupMapper") }
end
