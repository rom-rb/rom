require 'spec_helper'

describe 'Relationship - One To One' do
  before(:all) do
    setup_db

    insert_user 1, 'John',  18
    insert_user 2, 'Jane',  21
    insert_user 3, 'Piotr', 29

    insert_address 1, 3, 'Street 1/2', 'Krakow',  '12345'
    insert_address 2, 2, 'Street 1/2', 'Chicago', '54321'
    insert_address 3, 1, 'Street 2/4', 'Boston',  '67890'

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

      class UserAddressMapper < DataMapper::Mapper::VeritasMapper
        model User

        map :id,      :type => Integer, :to => :user_id, :key => true
        map :name,    :type => String,  :to => :username
        map :age,     :type => Integer
        map :address, :type => Address
      end

      class Mapper < DataMapper::Mapper::VeritasMapper
        model         User
        relation_name :users
        repository    :postgres

        map :id,   :type => Integer, :key => true
        map :name, :type => String,  :to  => :username
        map :age,  :type => Integer

        has 1, :address, :mapper => UserAddressMapper do |address|
          rename(:id => :user_id).join(address)
        end

        has 1, :home_address, :parent => :address do
          restrict { |r| r.city.eq('Krakow') }
        end
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
    user = user_mapper.include(:address).to_a.last
    address = user.address

    address.should be_instance_of(Address)
    address.id.should eql(3)
    address.city.should eql('Boston')
  end

  it 'loads restricted association' do
    user = user_mapper.include(:home_address).to_a.last
    address = user.address

    address.should be_instance_of(Address)
    address.id.should eql(1)
    address.city.should eql('Krakow')
  end

  it 'finds users with matching address' do
    users = user_mapper.include(:address).restrict { |r| r.city.eq('Krakow') }.to_a

    users.should have(1).item

    user = users.first

    user.name.should eql('Piotr')
    user.address.id.should eql(1)
    user.address.city.should eql('Krakow')
  end
end
