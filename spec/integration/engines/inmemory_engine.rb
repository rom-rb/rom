require 'spec_helper'
require 'data_mapper/engine/inmemory_engine'

describe Engine::InmemoryEngine do
  before(:suite) do
    DataMapper.engines[:memory] = Engine::InmemoryEngine.new

    User = Class.new(OpenStruct)

    class UserMapper < DataMapper::Relation::Mapper
      repository    :memory
      relation_name :users
      model         User

      map :id,   Integer, :key => true
      map :name, String,  :to => :UserName
      map :age,  Integer, :to => :UserAge
    end

    DataMapper.finalize
  end

  before {
    mapper.relation.relation.reset!
  }

  let(:mapper) { DataMapper[User] }

  describe '#insert' do
    it "adds user to the relation" do
      user = User.new(:name => 'Piotr', :age => 29)
      mapper.insert(user)
      user.id.should be(1)
    end
  end

  describe '#delete' do
    it "deletes user to the relation" do
      user = User.new(:name => 'Piotr', :age => 29)
      mapper.insert(user)
      mapper.delete(user)
      mapper.all.should be_empty
    end
  end
end
