require 'spec_helper_integration'
require 'data_mapper/engine/in_memory'

describe Engine::InMemory::Engine do
  before(:all) do
    DM_ENV.engines[:memory] = Engine::InMemory::Engine.new

    if Object.const_defined?(:User)
      Object.send(:remove_const, :User)
    end

    DM_ENV.build(user_model, :memory) do
      relation_name :users

      map :key,  Integer, :key => true
      map :name, String,  :to => :UserName
      map :age,  Integer, :to => :UserAge
    end
  end

  let!(:user_model) { mock_model('User') }
  let!(:mapper)     { DM_ENV[user_model] }

  before { mapper.relation.relation.reset!  }


  describe '#insert' do
    it "adds user to the relation" do
      user = user_model.new(:key => nil, :name => 'Piotr', :age => 29)
      mapper.insert(user)
      user.key.should be(1)
    end
  end

  describe '#delete' do
    it "deletes user to the relation" do
      user = user_model.new(:name => 'Piotr', :age => 29)
      mapper.insert(user)
      mapper.delete(user)
      mapper.all.should be_empty
    end
  end
end
