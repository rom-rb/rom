require 'spec_helper_integration'

describe "Inserting new objects with ARel" do
  before(:all) do
    setup_db

    class User
      include DataMapper::Model

      attribute :id,   Integer, :key => true
      attribute :name, String
      attribute :age,  Integer

      DM_ENV.build(User, :postgres) do
        relation_name :users

        map :id,   Integer, :key => true
        map :name, String,  :to  => :username
        map :age,  Integer
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :User)
  end

  it "actually works ZOMG" do
    mapper = DM_ENV[User]

    user = User.new(:name => 'Piotr', :age => 29)
    mapper.insert(user)

    user = mapper.first

    user.should be_instance_of(User)
    user.id.should be(1)
    user.name.should eql('Piotr')
    user.age.should be(29)
  end
end
