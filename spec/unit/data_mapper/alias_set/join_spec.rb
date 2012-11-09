require 'spec_helper'

describe AliasSet, '#join' do
  subject { object.join(other) }

  let(:relation_name) { :users }
  let(:object)        { described_class.new(relation_name, attributes) }
  let(:attributes)    { Mapper::AttributeSet.new }
  let(:id)            { mock_attribute(:id, Integer) }
  let(:name)          { mock_attribute(:name, String) }

  let(:other_relation_name) { :orders }
  let(:other)               { described_class.new(other_relation_name, other_attributes) }
  let(:other_attributes)    { Mapper::AttributeSet.new }
  let(:other_id)            { mock_attribute(:other_id, Integer) }
  let(:other_product)       { mock_attribute(:other_product, String) }

  before do
    attributes << id << name
    other_attributes << other_id << other_product
  end

  it { should be_instance_of(AliasSet::Joined) }

  its(:to_a) { should == [ object, other ] }
end
