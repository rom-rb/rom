require 'spec_helper'

describe AliasSet, '#exclude' do
  subject { object.exclude(*names) }

  let(:object) { described_class.new(relation_name, attributes) }

  let(:relation_name) { :users }
  let(:id)            { Mapper::Attribute.build(:id, :type => Integer, :key => true) }
  let(:name)          { Mapper::Attribute.build(:name, :type => String, :to => :username) }
  let(:attributes)    { Mapper::AttributeSet.new << id << name }

  context 'with no attribute names to exclude' do
    let(:names)   { [] }
    its(:to_hash) { should eql(object.to_hash) }
  end

  context 'with non-existing attribute names to exclude' do
    let(:names)   { [ :foo ] }
    its(:to_hash) { should eql(object.to_hash) }
  end

  context 'with existing attribute names to exclude' do
    let(:names)   { [ :name ] }
    its(:to_hash) { should eql(:id => :user_id) }
  end
end
