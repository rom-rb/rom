require 'spec_helper'

describe Mapper::Builder, '#mapper' do
  subject { object.mapper }

  let(:object) { described_class.new(connector, source_mapper_class) }

  let(:source_model) { mock_model('User')  }
  let(:target_model) { mock_model('Order') }

  let(:is_via)               { false }
  let(:via)                  { nil   }
  let(:is_collection_target) { true  }

  let(:relation)     { mock('relation') }
  let(:relationship) { mock('relationship', :name => :orders) }

  let(:source_attributes)   { Mapper::AttributeSet.new << Mapper::Attribute.build(:id, :type => Integer) << Mapper::Attribute.build(:name, :type => String, :to => :username) }
  let(:source_mapper_class) { mock_mapper(source_model, source_attributes) }

  let(:target_attributes)   { Mapper::AttributeSet.new << Mapper::Attribute.build(:id, :type => Integer) << Mapper::Attribute.build(:user_id, :type => Integer) << Mapper::Attribute.build(:product, :type => String) }
  let(:target_mapper_class) { mock_mapper(target_model, target_attributes)}

  let(:relations) { source_mapper_class.relations }

  context "when connector is not via other" do
    let(:connector) {
      mock_connector(
        :name               => :orders,
        :left               => mock_node(:users),
        :right              => mock_node(:orders),
        :source_model       => source_model,
        :target_model       => target_model,
        :source_name        => :users,
        :target_name        => :orders,
        :source_aliases     => AliasSet.new(:user, source_attributes),
        :target_aliases     => AliasSet.new(:order, target_attributes, [ :user_id ]),
        :collection_target? => is_collection_target,
        :relationship       => relationship,
        :relation           => relation,
        :relations          => relations
      )
    }

    before do
      DataMapper.mapper_registry << target_mapper_class.new(relation)
      source_mapper_class.relations.add_connector(connector.name, connector)
    end

    it { should be_kind_of(Mapper::Relation) }

    it "remaps source model attributes" do
      subject.attributes[:id].field.should eql(:user_id)
      subject.attributes[:name].field.should eql(:user_username)
    end

    it "sets embedded collection attribute" do
      user_orders = subject.attributes[:orders]

      user_orders.should be_instance_of(Mapper::Attribute::EmbeddedCollection)
    end

    it "remaps target model attributes" do
      target_mapper = subject.attributes[:orders].mapper

      target_mapper.attributes[:id].field.should eql(:order_id)
      target_mapper.attributes[:user_id].field.should eql(:user_id)
      target_mapper.attributes[:product].field.should eql(:order_product)
    end

    it "extends the mapper with OneToMany iterator" do
      subject.should be_kind_of(Relationship::OneToMany::Iterator)
    end
  end

  context "when connector is via other" do
    let(:via_relationship) { mock('relationship', :name => via) }

    let(:is_via)         { true }
    let(:via)            { :user_order_infos }
    let(:other_relation) { mock('other_relation') }

    let(:via_source_model)        { mock_model('UserOrderInfo')  }
    let(:via_source_attributes)   { Mapper::AttributeSet.new << Mapper::Attribute.build(:user_id, :type => Integer) << Mapper::Attribute.build(:order_id, :type => Integer) }
    let(:via_source_mapper_class) { mock_mapper(via_source_model, via_source_attributes) }

    let(:connector) {
      mock_connector(
        :name               => :users_X_user_order_infos_X_orders,
        :left               => mock_node(:users),
        :right              => mock_node(:user_order_infos_X_orders),
        :source_model       => source_model,
        :target_model       => target_model,
        :source_name        => :users,
        :target_name        => :user_order_infos_X_orders,
        :source_aliases     => AliasSet.new(:user, source_attributes, [ :name ]),
        :target_aliases     => AliasSet.new(:order, target_attributes, [ :user_id, :product ]),
        :collection_target? => is_collection_target,
        :relationship       => relationship,
        :relation           => relation,
        :relations          => relations
      )
    }

    let(:via_connector) {
      mock_connector(
        :name               => :user_order_infos_X_orders,
        :left               => mock_node(:orders),
        :right              => mock_node(:user_order_infos),
        :source_name        => :user_order_infos,
        :target_name        => :orders,
        :source_model       => via_source_model,
        :target_model       => target_model,
        :source_aliases     => AliasSet.new(:user_order_info, via_source_attributes, [ :user_id, :order_id ]),
        :target_aliases     => AliasSet.new(:order, target_attributes, [ :user_id, :product ]),
        :relationship       => via_relationship,
        :collection_target? => true,
        :relation           => other_relation,
        :relations          => relations
      )
    }

    before do
      DataMapper.mapper_registry << target_mapper_class.new(relation)
      DataMapper.mapper_registry << via_source_mapper_class.new(other_relation)

      source_mapper_class.relations.add_connector(connector.name, connector)
      source_mapper_class.relations.add_connector(via_connector.name, via_connector)
    end

    it { should be_kind_of(Mapper::Relation) }

    it "remaps target model attributes using connector aliases" do
      subject.attributes[:orders].mapper.attributes[:product].field.should eql(:product)
    end
  end
end
