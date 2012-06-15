require 'spec_helper'

describe 'Relationship - One To One' do
  before(:all) do
    setup_db

    insert_user 1, 'John', 18
    insert_user 2, 'Jane', 21

    insert_address 1, 1, 'Street 1/2', 'Chicago', '12345'
    insert_address 2, 2, 'Street 2/4', 'Boston',  '67890'

    class Address
      attr_reader :id, :street, :city, :zipcode

      def initialize(attributes)
        @id, @street, @city, @zipcode = attributes.values_at(
          :id, :street, :city, :zipcode)
      end

      class Mapper < DataMapper::Mapper::VeritasMapper
        map :id,      :type => Integer, :key => true
        map :user_id, :type => Integer
        map :street,  :type => String
        map :city,    :type => String
        map :zipcode, :type => String

        model         Address
        relation_name :addresses
      end
    end

    class User
      attr_reader :id, :name, :age, :address

      def initialize(attributes)
        @id, @name, @age = attributes.values_at(:id, :name, :age)
        @address = attributes[:address]
      end

      class Mapper < DataMapper::Mapper::VeritasMapper
        map :id,   :type => Integer, :key => true
        map :name, :type => String,  :to  => :username
        map :age,  :type => Integer

        model         User
        relation_name :users
      end
    end
  end

  let(:user_relation) do
    DataMapper.relation_registry << User::Mapper.base_relation
    Veritas::Relation::Gateway.new(
      DATABASE_ADAPTER, DataMapper.relation_registry[:users])
  end

  let(:address_relation) do
    DataMapper.relation_registry << Address::Mapper.base_relation
    Veritas::Relation::Gateway.new(
      DATABASE_ADAPTER, DataMapper.relation_registry[:addresses])
  end

  it 'loads associated object' do
    User::Mapper.map :address,
      :type   => DataMapper::Mapper::Relationship::OneToOne,
      :mapper => Address::Mapper.new(address_relation)

    user_mapper = User::Mapper.new(user_relation)
    user        = user_mapper.include(:address).first

    address_mapper = Address::Mapper.new(address_relation)
    address        = address_mapper.first

    user.address.should be_instance_of(Address)
    user.address.id.should eql(address.id)
  end
end
