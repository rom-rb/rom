require 'spec_helper_integration'

unless DataMapper.engines[:postgres_arel]
  DataMapper.setup(
    :postgres_arel,
    'postgres://postgres@localhost/dm-mapper_test',
    DataMapper::Engine::Arel::Engine
  )
end

describe "Inserting new objects with ARel" do
  before(:all) do
    setup_db

    class User
      include DataMapper::Model

      attribute :id,   Integer, :key => true
      attribute :name, String
      attribute :age,  Integer

      class Mapper < DataMapper::Mapper::Relation

        model         User
        relation_name :users
        repository    :postgres_arel

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
    mapper = DataMapper[User]

    user = User.new(:name => 'Piotr', :age => 29)
    mapper.insert(user)

    user = mapper.first

    user.should be_instance_of(User)
    user.id.should be(1)
    user.name.should eql('Piotr')
    user.age.should be(29)
  end
end
