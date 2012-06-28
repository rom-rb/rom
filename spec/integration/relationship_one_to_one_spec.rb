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
        repository    :postgres
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
        repository    :postgres
      end
    end
  end

  let(:user_mapper) do
    DataMapper[User]
  end

  let(:address_mapper) do
    DataMapper[Address]
  end

  it 'loads associated object' do
    User::Mapper.has(1, :address, :mapper => address_mapper)

    user    = user_mapper.include(:address).first
    address = address_mapper.first

    user.address.should be_instance_of(Address)
    user.address.id.should eql(address.id)
  end
end
