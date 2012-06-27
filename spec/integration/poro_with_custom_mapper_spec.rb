require 'spec_helper'

describe 'PORO with a custom mapper' do
  before(:all) do
    setup_db

    insert_user 1, 'John', 18
    insert_user 2, 'Jane', 21

    class User
      attr_reader :id, :name, :age

      def initialize(attributes)
        @id, @name, @age = attributes.values_at(:id, :name, :age)
      end

      class Mapper < DataMapper::Mapper::VeritasMapper
        map :id, :key => true, :type => Integer
        map :name, :to => :username, :type => String
        map :age, :type => Integer

        model         User
        relation_name :users
        repository    :postgres
      end
    end
  end

  let(:mapper) do
    DataMapper[User]
  end

  it 'finds all users' do
    mapper.first.should be_instance_of(User)
  end

  it 'finds users matching one name' do
    users = mapper.restrict { |r| r.username.eq('John') }.to_a

    users.should have(1).item

    user = users.first
    user.should be_instance_of(User)
    user.name.should eql('John')
  end

  it 'finds users matching two names' do
    users = mapper.restrict { |r| r.username.eq('John').or(r.username.eq('Jane')) }.to_a

    users.should have(2).item

    user1, user2 = users

    user1.should be_instance_of(User)
    user2.should be_instance_of(User)

    user1.name.should eql('John')
    user2.name.should eql('Jane')
  end

  it 'finds users matching name and age' do
    users = mapper.restrict { |r| r.username.eq('Jane').and(r.age.gt(18)) }.to_a

    users.should have(1).item

    user = users.first
    user.should be_instance_of(User)
    user.name.should eql('Jane')
  end

  it 'sorts by name, age and id' do
    pending

    users = User::Mapper.new(relation.sort_by { |r| [ r.username, r.age, r.id ] }).to_a

    user1, user2 = users

    user1.name.should eql('Jane')
    user2.name.should eql('John')
  end
end
