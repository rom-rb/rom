require 'spec_helper_integration'

describe "Using Arel engine" do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    users_collection = DM_ENV.engines[:mongo].db.drop_collection('users')
    users_collection = DM_ENV.engines[:mongo].db['users']

    users_collection.insert(:name => 'John',  :age => 18, :address => { :city => 'Wroclaw', :street => 'Street 1', :zipcode => '12345'})
    users_collection.insert(:name => 'Jane',  :age => 21, :address => { :city => 'Warsaw',  :street => 'Street 2', :zipcode => '54321'})
    users_collection.insert(:name => 'Piotr', :age => 29, :address => { :city => 'Krakow',  :street => 'Street 3', :zipcode => '34251'})

    address_mapper.model(address_model)
    user_mapper.map :address, address_model, :mapper => address_mapper.new, :to => 'address'
  end

  let(:user_mapper) {
    DM_ENV.build(user_model, :mongo) do
      relation_name :users

      map :id,   Integer, :to => '_id', :key => true
      map :name, String,  :to => 'name'
      map :age,  Integer, :to => 'age'
    end
  }

  let(:address_mapper) {
    class AddressMapper < Mapper
      map :street,  String, :to => 'street'
      map :city,    String, :to => 'city'
      map :zipcode, String, :to => 'zipcode'
      self
    end
  }

  let(:user_model) {
    user = Class.new {
      include DataMapper::Model
      include Equalizer.new(:id, :name, :age)

      attribute :id,   String
      attribute :name, String
      attribute :age,  Integer
    }
    user.attribute :address, address_model
    user
  }

  let(:address_model) {
    Class.new {
      include DataMapper::Model
      include Equalizer.new(:street, :city, :zipcode)

      attribute :street,  String
      attribute :city,    String
      attribute :zipcode, String
    }
  }

  after(:all) {
    Object.send(:remove_const, :AddressMapper)
  }

  it "loads user objects with embedded addresses" do
    mapper = DM_ENV[user_model]
    users  = mapper.all

    users.should have(3).items

    user1, user2, user3 = users

    user1.name.should eql('John')
    user1.age.should be(18)
    user1.address.should be_instance_of(address_model)
    user1.address.street.should eql('Street 1')
    user1.address.city.should eql('Wroclaw')
    user1.address.zipcode.should eql('12345')

    user2.name.should eql('Jane')
    user2.age.should be(21)
    user2.address.should be_instance_of(address_model)
    user2.address.street.should eql('Street 2')
    user2.address.city.should eql('Warsaw')
    user2.address.zipcode.should eql('54321')

    user3.name.should eql('Piotr')
    user3.age.should be(29)
    user3.address.should be_instance_of(address_model)
    user3.address.street.should eql('Street 3')
    user3.address.city.should eql('Krakow')
    user3.address.zipcode.should eql('34251')
  end
end
