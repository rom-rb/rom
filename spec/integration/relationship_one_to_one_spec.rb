require 'spec_helper_integration'

describe 'Relationship - One To One with generated mapper' do
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

      class Mapper < DataMapper::Mapper::Relation::Base

        model         Address
        relation_name :addresses
        repository    :postgres

        map :id,      Integer, :key => true
        map :user_id, Integer
        map :street,  String
        map :city,    String
        map :zipcode, String
      end
    end

    class User
      attr_reader :id, :name, :age, :address, :home_address

      def initialize(attributes)
        @id, @name, @age = attributes.values_at(:id, :name, :age)
        @address         = attributes[:address]
        @home_address    = attributes[:home_address]
      end

      class Mapper < DataMapper::Mapper::Relation::Base

        model         User
        relation_name :users
        repository    :postgres

        map :id,   Integer, :key => true
        map :name, String,  :to  => :username
        map :age,  Integer

        has 1, :address, Address

        has 1, :home_address, Address do
          restrict { |r| r.address_city.eq('Krakow') }
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

  it 'loads the object without association' do
    user = user_mapper.all.first

    user.should be_instance_of(User)
    user.id.should eql(1)
    user.name.should eql('John')
    user.age.should eql(18)
  end

  it 'loads associated object' do
    user    = user_mapper.include(:address).to_a.last
    address = user.address

    address.should be_instance_of(Address)
    address.id.should eql(3)
    address.city.should eql('Boston')
  end

  it 'loads restricted association' do

    user = user_mapper.include(:home_address).to_a.last
    address = user.home_address

    address.should be_instance_of(Address)
    address.id.should eql(1)
    address.city.should eql('Krakow')
  end

  it 'finds users with matching address' do
    user_address_mapper = user_mapper.include(:address)
    users               = user_address_mapper.restrict { |r| r.address_city.eq('Krakow') }.to_a

    users.should have(1).item

    user = users.first

    user.name.should eql('Piotr')
    user.address.id.should eql(1)
    user.address.city.should eql('Krakow')
  end

  it 'finds users with matching address using mapper query API' do
    pending "Query doesn't support nested conditions"

    users = user_mapper.include(:address).find(:address => { :city => "Krakow" })

    users.should have(1).item

    user = users.first

    user.name.should eql('Piotr')
    user.address.id.should eql(1)
    user.address.city.should eql('Krakow')
  end
end
