require 'spec_helper'

describe 'PORO with a custom mapper' do
  before(:all) do
    setup_db

    insert_user 1, 'John', 18
    insert_user 2, 'Jane', 21
  end

  let(:relation) do
    DataMapper.relation_registry << User::Mapper.base_relation
    Veritas::Relation::Gateway.new(DATABASE_ADAPTER, DataMapper.relation_registry[:users])
  end

  class User
    attr_reader :id, :name, :age

    def initialize(attributes)
      @id, @name, @age = attributes.values_at(:id, :name, :age)
    end

    class Mapper < DataMapper::Mapper::VeritasMapper
      map :id, :type => Integer
      map :name, :to => :username, :type => String
      map :age, :type => Integer

      model         User
      relation_name :users
    end
  end

  it 'finds all users' do
    user = User::Mapper.new(relation).first

    user.should be_instance_of(User)
  end

  it 'finds users matching one name' do
    users = User::Mapper.new(relation.restrict { |r| r.username.eq('John') }).to_a

    users.should have(1).item

    user = users.first
    user.should be_instance_of(User)
    user.name.should eql('John')
  end

  it 'finds users matching two names' do
    users = User::Mapper.new(relation.restrict { |r| r.username.eq('John').or(r.username.eq('Jane')) }).to_a

    users.should have(2).item

    user1, user2 = users

    user1.should be_instance_of(User)
    user2.should be_instance_of(User)

    user1.name.should eql('John')
    user2.name.should eql('Jane')
  end

  it 'finds users matching name and age' do
    users = User::Mapper.new(relation.restrict { |r| r.username.eq('Jane').and(r.age.gt(18)) }).to_a

    users.should have(1).item

    user = users.first
    user.should be_instance_of(User)
    user.name.should eql('Jane')
  end

  it 'sorts by name, age and id' do
    users = User::Mapper.new(relation.sort_by { |r| [ r.username, r.age, r.id ] }).to_a

    user1, user2 = users

    user1.name.should eql('Jane')
    user2.name.should eql('John')
  end
end
