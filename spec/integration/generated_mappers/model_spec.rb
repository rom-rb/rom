require 'spec_helper_integration'

describe "Generated mapper from model definition" do
  it "generates mappers for the model" do
    class Order
      include DataMapper::Model

      attribute :id,      Integer
      attribute :product, String
    end

    class User
      include DataMapper::Model

      attribute :id,     Integer
      attribute :name,   String
      attribute :age,    Integer
      attribute :orders, Array[Order]
    end

    order_mapper = DataMapper.generate_mapper_for(Order) do
      key :id
    end

    user_mapper = DataMapper.generate_mapper_for(User) do
      key :id
      map :name, :to => :username
    end

    DataMapper.finalize

    user_mapper.attributes[:id].key?.should be(true)
    user_mapper.attributes[:name].should be_kind_of(DataMapper::Mapper::Attribute::Primitive)
    user_mapper.attributes[:name].field.should be(:username)

    user_mapper.attributes[:orders].should be_kind_of(DataMapper::Mapper::Attribute::EmbeddedCollection)
    user_mapper.attributes[:orders].mapper.should be(DataMapper[Order])
  end
end
