require 'spec_helper_integration'

describe "Using Arel engine" do
  before(:all) do
    setup_db

    insert_user 1, 'John',  18
    insert_user 2, 'Jane',  21
    insert_user 3, 'Piotr', 29

    insert_address 1, 3, 'Street 1/2', 'Krakow',  '12345'
    insert_address 2, 2, 'Street 1/2', 'Chicago', '54321'
    insert_address 3, 1, 'Street 2/4', 'Boston',  '67890'

    if Object.const_defined?(:User)
      Object.send(:remove_const, :User)
    end

    class Address
      include DataMapper::Model

      attribute :id,      Integer, :key => true
      attribute :city,    String
      attribute :street,  String
      attribute :zipcode, String
    end

    DM_ENV.build(Address, :postgres) do
      relation_name :addresses

      key(:id)
    end

    class User
      include DataMapper::Model

      attribute :id,      Integer, :key => true
      attribute :name,    String
      attribute :age,     Integer
      attribute :address, Address
    end

    DM_ENV.build(User, :postgres) do
      relation_name :users

      key :id
      map :name, String,  :to  => :username
      has 1, :address, Address
    end
  end

  it "actually works ZOMG" do
    users = DM_ENV[User].include(:address).to_a

    users.should have(3).items

    user1, user2, user3 = users

    user1.name.should eql('John')
    user1.age.should be(18)

    user2.name.should eql('Jane')
    user2.age.should be(21)

    user3.name.should eql('Piotr')
    user3.age.should be(29)
  end
end
