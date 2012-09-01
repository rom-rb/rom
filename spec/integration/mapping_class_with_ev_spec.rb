require 'spec_helper_integration'

describe 'PORO with an embedded value' do
  before(:all) do
    setup_db

    insert_user 1, 'John', 18
    insert_user 2, 'Jane', 21

    insert_address 1, 1, 'Street 1/2', 'Chicago', '12345'
    insert_address 2, 2, 'Street 2/4', 'Boston',  '67890'

    class Address
      attr_reader :street, :city, :zipcode

      def initialize(*attributes)
        @street, @city, @zipcode = attributes
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
        @address = Address.new(*attributes.values_at(:street, :city, :zipcode))
      end

      class Mapper < DataMapper::Mapper::VeritasMapper
        map :id,   :type => Integer, :key => true
        map :name, :type => String,  :to  => :username
        map :age,  :type => Integer

        # address attributes
        map :street,  :type => String
        map :city,    :type => String
        map :zipcode, :type => String

        model         User
        relation_name :users
        repository    :postgres
      end
    end
  end

  let(:operation) do
    left  = DataMapper.relation_registry[:users]
    right = DataMapper.relation_registry[:addresses]

    left.join(right).restrict { |r| r.id.eq(r.user_id) }
  end

  it 'loads a user with an address' do
    pending

    mapper = User::Mapper.new(operation.optimize)
    users  = mapper.to_a

    user1, user2 = users

    user1.name.should eql('John')
    user1.address.should be_instance_of(Address)
    user1.address.zipcode.should eql('12345')
    user1.address.city.should eql('Chicago')
    user1.address.street.should eql('Street 1/2')

    user2.name.should eql('Jane')
    user2.address.should be_instance_of(Address)
    user2.address.zipcode.should eql('67890')
    user2.address.city.should eql('Boston')
    user2.address.street.should eql('Street 2/4')
  end
end
