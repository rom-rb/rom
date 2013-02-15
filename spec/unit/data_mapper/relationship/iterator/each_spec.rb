require 'spec_helper'

describe Relationship::Iterator, '#each' do
  let(:source_mapper)     { mock_mapper(source_model, source_attributes).new(DM_ENV, relation) }
  let(:target_mapper)     { mock_mapper(target_model, target_attributes).new(DM_ENV) }

  let(:source_model)      { mock_model(:User) }
  let(:target_model)      { mock_model(:Order) }

  let(:source_attributes) { [ id.clone(:to => :user_id), name, orders ] }
  let(:target_attributes) { [ id.clone(:to => :order_id), user_id, product ] }

  let(:id)      { Attribute.build(:id, :type => Integer, :key => true) }

  let(:name)    { Attribute.build(:name, :type => String) }
  let(:orders)  { Attribute.build(:orders, :type => target_model, :mapper => target_mapper, :collection => true) }

  let(:user_id) { Attribute.build(:user_id, :type => Integer) }
  let(:product) { Attribute.build(:product, :type => String) }

  let(:result1)  { { :user_id => 1, :name => 'Piotr',  :order_id => 1, :product => 'apple' } }
  let(:result2)  { { :user_id => 1, :name => 'Piotr',  :order_id => 2, :product => 'orange' } }
  let(:result3)  { { :user_id => 2, :name => 'Martin', :order_id => 3, :product => 'orange' } }
  let(:result4)  { { :user_id => 2, :name => 'Martin', :order_id => 4, :product => 'apple' } }
  let(:result)   { [ result1, result2, result3, result4 ] }

  let(:relation) { mock('relation', :to_a => result) }

  let(:object) { source_mapper.extend(described_class) }

  let(:user_1) { source_model.new(:id => 1, :name => 'Piotr',  :orders => [ order_1, order_2 ]) }
  let(:user_2) { source_model.new(:id => 2, :name => 'Martin', :orders => [ order_3, order_4 ]) }

  let(:order_1) { target_model.new(:id => 1, :user_id => 1, :product => 'apple') }
  let(:order_2) { target_model.new(:id => 2, :user_id => 1, :product => 'orange') }
  let(:order_3) { target_model.new(:id => 3, :user_id => 2, :product => 'orange') }
  let(:order_4) { target_model.new(:id => 4, :user_id => 2, :product => 'apple') }

  context "with a block" do
    subject { object.to_a }

    it { should have(2).items }

    it { should include(user_1) }
    it { should include(user_2) }
  end

  context "without a block" do
    subject { object.each }

    it { should be_instance_of(Enumerator) }
  end
end
