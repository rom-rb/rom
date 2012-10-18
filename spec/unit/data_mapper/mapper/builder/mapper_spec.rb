require 'spec_helper'

describe Mapper::Builder, '#mapper' do
  subject { object.mapper }

  let(:object) { described_class.new(connector, source_mapper_class) }

  let(:source_model) { mock_model('User')  }
  let(:target_model) { mock_model('Order') }

  let(:is_via)               { false }
  let(:via)                  { nil   }
  let(:is_collection_target) { true  }

  let(:relation) { mock('relation') }

  let(:connector) {
    mock_connector(
      :name               => :user_orders,
      :source_model       => source_model,
      :target_model       => target_model,
      :source_aliases     => AliasSet.new(:user, source_attributes),
      :target_aliases     => AliasSet.new(:order, target_attributes, [ :user_id ]),
      :via?               => is_via,
      :via                => via,
      :collection_target? => is_collection_target,
      :relation           => relation
    )
  }

  let(:source_attributes)   { Mapper::AttributeSet.new << Mapper::Attribute.build(:id, :type => Integer) << Mapper::Attribute.build(:name, :type => String, :to => :username) }
  let(:source_mapper_class) { mock_mapper(source_model, source_attributes) }

  let(:target_attributes)   { Mapper::AttributeSet.new << Mapper::Attribute.build(:id, :type => Integer) << Mapper::Attribute.build(:user_id, :type => Integer) << Mapper::Attribute.build(:product, :type => String) }
  let(:target_mapper_class) { mock_mapper(target_model, target_attributes)}

  before do
    DataMapper.mapper_registry << target_mapper_class.new(relation)
  end

  context "when connector is not via other" do
    it { should be_kind_of(Mapper::Relation) }

    it "remaps source model attributes" do
      subject.attributes[:id].field.should eql(:user_id)
      subject.attributes[:name].field.should eql(:user_username)
    end

    it "sets embedded collection attribute" do
      user_orders = subject.attributes[:user_orders]

      user_orders.should be_instance_of(Mapper::Attribute::EmbeddedCollection)
    end

    it "remaps target model attributes" do
      target_mapper = subject.attributes[:user_orders].mapper

      target_mapper.attributes[:id].field.should eql(:order_id)
      target_mapper.attributes[:user_id].field.should eql(:user_id)
      target_mapper.attributes[:product].field.should eql(:order_product)
    end

    it "extends the mapper with OneToMany iterator" do
      subject.should be_kind_of(Relationship::OneToMany::Iterator)
    end
  end

  context "when connector is via other" do
    let(:is_via)         { true }
    let(:via)            { :user_order_infos }
    let(:other_relation) { mock('other_relation') }

    let(:other_target_model)        { mock_model('UserOrderInfo')  }
    let(:other_target_attributes)   { Mapper::AttributeSet.new << Mapper::Attribute.build(:user_id, :type => Integer) << Mapper::Attribute.build(:order_id, :type => Integer) }
    let(:other_target_mapper_class) { mock_mapper(other_target_model, other_target_attributes) }

    let(:other_connector) {
      mock_connector(
        :name               => :user_order_infos,
        :source_model       => source_model,
        :target_model       => other_target_model,
        :source_aliases     => AliasSet.new(:user, source_attributes, [ :name ]),
        :target_aliases     => AliasSet.new(:user_order_info, other_target_attributes, [ :user_id, :order_id ]),
        :via?               => false,
        :collection_target? => true,
        :relation           => other_relation
      )
    }

    before do
      DataMapper.mapper_registry << other_target_mapper_class.new(other_relation)
      DataMapper.relation_registry.add_connector(other_connector)
    end

    it { should be_kind_of(Mapper::Relation) }

    it "remaps source model attributes using via connector aliases" do
      subject.attributes[:name].field.should eql(:username)
    end
  end
end
