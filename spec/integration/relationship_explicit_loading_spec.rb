require 'spec_helper_integration'

describe 'Relationship - One To One - Explicit Loading' do
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

      DM_ENV.build(Address, :postgres) do
        relation_name :addresses

        map :id,      Integer, :key => true
        map :user_id, Integer
        map :street,  String
        map :city,    String
        map :zipcode, String
      end
    end


    class User
      attr_reader :id, :name, :age, :address

      def initialize(attributes)
        @id, @name, @age = attributes.values_at(:id, :name, :age)
        @address = attributes[:address]
      end

      DM_ENV.build(User, :postgres) do
        relation_name :users

        map :id,   Integer, :key => true
        map :name, String,  :to  => :username
        map :age,  Integer
      end
    end
  end

  let(:user_mapper) do
    DM_ENV[User]
  end

  let(:address_mapper) do
    DM_ENV[Address]
  end

  it 'loads parent and then child' do
    pending "VeritasRelation#rename is not finished yet"

    user    = user_mapper.to_a.last
    address = address_mapper.join(user_mapper.rename(:id => :user_id)).first

    address.should be_instance_of(Address)
    address.id.should eql(1)
    address.city.should eql('Krakow')
  end
end
