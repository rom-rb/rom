require 'spec_helper_integration'

describe "Using Arel engine" do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    users_collection = DM_ENV.engines[:mongo].db.drop_collection('users')
    users_collection = DM_ENV.engines[:mongo].db['users']

    users_collection.insert(:name => 'John',  :age => 18)
    users_collection.insert(:name => 'Jane',  :age => 21)
    users_collection.insert(:name => 'Piotr', :age => 29)

    user_mapper
  end

  let(:user_mapper) {
    DM_ENV.build(user_model, :mongo) do
      relation_name :users

      map :id,   Integer, :to => '_id', :key => true
      map :name, String,  :to => 'name'
      map :age,  Integer, :to => 'age'
    end
  }

  let(:user_model) {
    mock_model('User') {
      include DataMapper::Model

      attribute :id,   String, :key => true, :to => :_id
      attribute :name, String
      attribute :age,  Integer
    }
  }

  it "actually works ZOMG" do
    users = DM_ENV[user_model].all

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
