require 'spec_helper_integration'

describe 'Finding Many Objects', :type => :integration do
  before(:all) do
    setup_db

    insert_user 1, 'John',  23
    insert_user 2, 'Jane',  21
    insert_user 3, 'Jane',  22
    insert_user 4, 'Piotr', 20
    insert_user 5, 'Dan',   20

    insert_address 1, 1, 'Street 1/2', 'Chicago', '12345'
    insert_address 2, 5, 'Street 2/4', 'Boston',  '67890'

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
      attr_reader :id, :name, :age

      def initialize(attributes)
        @id, @name, @age = attributes.values_at(:id, :name, :age)
      end

      DM_ENV.build(User, :postgres) do
        relation_name :users

        map :id,   Integer, :key => true
        map :name, String,  :to  => :username
        map :age,  Integer
      end
    end
  end

  it 'finds many object matching search criteria' do
    users = DM_ENV[User].find(:name => 'Jane').to_a

    users.should have(2).items

    user1, user2 = users

    user1.should be_instance_of(User)
    user1.name.should eql('Jane')
    user1.age.should eql(21)

    user2.should be_instance_of(User)
    user2.age.should eql(22)
  end

  it 'finds and sorts objects' do
    users = DM_ENV[User].find(:name => 'Jane').order(:age, :name).to_a

    user1, user2 = users

    user1.should be_instance_of(User)
    user1.name.should eql('Jane')
    user1.age.should eql(21)

    user2.should be_instance_of(User)
    user1.name.should eql('Jane')
    user2.age.should eql(22)
  end

  it 'finds objects matching criteria from joined relation' do
    pending "Nested query conditions is not yet implemented"

    users = DM_ENV[User].find(:age => 20, :address => { :city => 'Boston' }).to_a

    users.should have(1).item

    user = users.first

    user.should be_instance_of(User)
    user.name.should eql('Dan')
    user.age.should eql(20)
  end

end
