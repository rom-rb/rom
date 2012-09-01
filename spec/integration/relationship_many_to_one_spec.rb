require 'spec_helper_integration'

describe 'Relationship - Many To One' do
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

      class Mapper < DataMapper::Mapper::VeritasMapper
        map :id,   :type => Integer, :key => true
        map :name, :type => String,  :to  => :username
        map :age,  :type => Integer

        model         User
        relation_name :users
        repository    :postgres
      end
    end

    class Address
      attr_reader :id, :street, :city, :zipcode, :user

      def initialize(attributes)
        @id, @street, @city, @zipcode, @user = attributes.values_at(
          :id, :street, :city, :zipcode, :user)
      end

      class AddressUserMapper < DataMapper::Mapper::VeritasMapper
        model Address

        map :address_id, :type => Integer, :to => :id
        map :user_id,    :type => Integer
        map :street,     :type => String
        map :city,       :type => String
        map :zipcode,    :type => String
        map :user,       :type => User
      end

      class Mapper < DataMapper::Mapper::VeritasMapper
        map :id,      :type => Integer, :key => true
        map :user_id, :type => Integer
        map :street,  :type => String
        map :city,    :type => String
        map :zipcode, :type => String

        belongs_to :user, :mapper => AddressUserMapper do |users|
          rename(:id => :address_id).join(users)
        end

        model         Address
        relation_name :addresses
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
    address = address_mapper.include(:user).first
    user    = user_mapper.first

    address.user.should be_instance_of(User)
    address.user.id.should eql(user.id)
  end
end
