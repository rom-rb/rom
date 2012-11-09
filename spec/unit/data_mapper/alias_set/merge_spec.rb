require 'spec_helper'

describe AliasSet, '#merge' do
  subject { object.merge(other) }

  let(:object) { described_class.new(relation_name, object_attributes) }
  let(:other)  { described_class.new(relation_name, other_attributes, other_excludes) }

  let(:relation_name)     { :users }
  let(:id)                { Mapper::Attribute.build(:id, :type => Integer) }
  let(:foo_id)            { Mapper::Attribute.build(:foo_id, :type => Integer) }
  let(:name)              { Mapper::Attribute.build(:name, :type => String, :to => :username) }
  let(:object_attributes) { Mapper::AttributeSet.new << id << foo_id }
  let(:other_attributes)  { Mapper::AttributeSet.new << name }
  let(:other_excludes)    { [ :foo_id ] }

  its(:to_hash) { should eql(:id => :user_id, :username => :user_username) }
end
