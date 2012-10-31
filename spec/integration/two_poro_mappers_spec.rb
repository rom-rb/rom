require 'spec_helper_integration'

describe 'Two PORO mappers' do
  before(:all) do
    setup_db

    insert_user 1, 'John', 18
    insert_user 2, 'Jane', 21

    insert_address 1, 1, 'Street 1/2', 'Chicago', '12345'
    insert_address 2, 2, 'Street 2/4', 'Boston',  '67890'

    class Address
      attr_reader :id, :street, :zipcode, :city

      def initialize(attributes)
        @id, @street, @zipcode, @city = attributes.values_at(:id, :name, :zipcode, :city)
      end

      class Mapper < DataMapper::Mapper::Relation

        model         Address
        relation_name :addresses
        repository    :postgres

        map :id,      Integer
        map :user_id, Integer
        map :street,  String
        map :zipcode, String
        map :city,    String
      end
    end

    class User
      attr_reader :id, :name, :age

      def initialize(attributes)
        @id, @name, @age = attributes.values_at(:id, :name, :age)
      end

      class Mapper < DataMapper::Mapper::Relation

        model         User
        relation_name :users
        repository    :postgres

        map :id,   Integer
        map :name, String, :to => :username
        map :age,  Integer
      end
    end
  end

  let(:operation) do
    left  = User::Mapper.relations[:users].relation
    right = Address::Mapper.relations[:addresses].relation.restrict { |r| r.city.eq('Boston') }

    left.join(right)
  end

  it 'finds user with a specific address' do
    users = User::Mapper.new(operation.restrict { |r| r.city.eq('Boston') }).to_a
    user  = users.first

    users.should have(1).item

    user.should be_instance_of(User)
    user.name.should eql('Jane')
  end

end
