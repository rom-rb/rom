require 'spec_helper_integration'

unless DataMapper.engines[:postgres_arel]
  DataMapper.setup(
    :postgres_arel,
    'postgres://postgres@localhost/dm-mapper_test',
    DataMapper::Engine::ArelEngine
  )
end

describe "Deleting objects with ARel" do
  before(:all) do
    setup_db

    insert_user 1, 'John',  18
    insert_user 2, 'Jane',  21
    insert_user 3, 'Piotr', 29

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
    user   = mapper.first

    mapper.delete(user)

    mapper.to_a.map(&:id).should_not include(1)
  end
end
