require 'spec_helper_integration'

describe 'Relationship - Many To One with generated mapper' do
  before(:all) do
    setup_db

    insert_user 1, 'John', 18
    insert_user 2, 'Jane', 21

    insert_address 1, 1, 'Street 1/2', 'Chicago', '12345'
    insert_address 2, 2, 'Street 2/4', 'Boston',  '67890'

    class User
      attr_reader :id, :name, :age, :address

      def initialize(attributes)
        @id, @name, @age = attributes.values_at(:id, :name, :age)
        @address = attributes[:address]
      end

      class Mapper < DataMapper::Relation::Mapper

        model         User
        relation_name :users
        repository    :postgres

        map :id,   Integer, :key => true
        map :name, String,  :to  => :username
        map :age,  Integer
      end
    end

    class Address
      attr_reader :id, :street, :city, :zipcode, :user

      def initialize(attributes)
        @id, @street, @city, @zipcode, @user = attributes.values_at(
          :id, :street, :city, :zipcode, :user)
      end

      class Mapper < DataMapper::Relation::Mapper
        model         Address
        relation_name :addresses
        repository    :postgres

        map :id,      Integer, :key => true
        map :user_id, Integer
        map :street,  String
        map :city,    String
        map :zipcode, String

        belongs_to :user, User
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
    mapper  = address_mapper.include(:user)
    address = mapper.first
    user    = user_mapper.first

    address.user.should be_instance_of(User)
    address.user.id.should eql(user.id)
  end
end
