require 'spec_helper'

describe Relationship::Iterator, '#each' do
  let(:source_mapper)     { mock_mapper(source_model, source_attributes).new(relation) }
  let(:target_mapper)     { mock_mapper(target_model, target_attributes).new }

  let(:source_model)      { mock_model(:User) }
  let(:target_model)      { mock_model(:Order) }

  let(:source_attributes) { [ id.clone(:to => :user_id), name, orders ] }
  let(:target_attributes) { [ id.clone(:to => :order_id), user_id, product ] }

  let(:id)      { Mapper::Attribute.build(:id, :type => Integer, :key => true) }

  let(:name)    { Mapper::Attribute.build(:name, :type => String) }
  let(:orders)  { Mapper::Attribute.build(:orders, :type => target_model, :mapper => target_mapper, :collection => true) }

  let(:user_id) { Mapper::Attribute.build(:user_id, :type => Integer) }
  let(:product) { Mapper::Attribute.build(:product, :type => String) }

  let(:result1)  { { :user_id => '1', :name => 'Piotr',  :order_id =>'1', :product => 'apple' } }
  let(:result2)  { { :user_id => '1', :name => 'Piotr',  :order_id =>'2', :product => 'orange' } }
  let(:result3)  { { :user_id => '2', :name => 'Martin', :order_id =>'3', :product => 'orange' } }
  let(:result4)  { { :user_id => '2', :name => 'Martin', :order_id =>'4', :product => 'apple' } }
  let(:result)   { [ result1, result2, result3, result4 ] }
  let(:relation) { mock('relation', :to_a => result) }

  let(:object) { source_mapper.extend(Relationship::Iterator) }

  context "with a block" do
    subject { object.to_a }

    it { should have(2).item }

    it "loads source with target collection" do
      pending if RUBY_VERSION < '1.9'

      user1 = subject[0]

      user1.should be_instance_of(source_model)
      user1.name.should eql('Piotr')
      user1.orders.should have(2).items

      order1, order2 = user1.orders

      order1.should be_instance_of(target_model)
      order1.product.should eql('apple')

      order2.should be_instance_of(target_model)
      order2.product.should eql('orange')

      user2 = subject[1]

      user2.should be_instance_of(source_model)
      user2.name.should eql('Martin')
      user2.orders.should have(2).items

      order3, order4 = user2.orders

      order3.should be_instance_of(target_model)
      order3.product.should eql('orange')

      order4.should be_instance_of(target_model)
      order4.product.should eql('apple')
    end
  end

  context "without a block" do
    subject { object.each }

    it { should be_instance_of(Enumerator) }
  end
end
