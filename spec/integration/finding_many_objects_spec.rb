require 'spec_helper'

describe 'Finding Many Objects' do
  before(:all) do
    setup_db

    insert_user 1, 'John',  23
    insert_user 2, 'Jane',  21
    insert_user 3, 'Jane',  22
    insert_user 4, 'Piotr', 20

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

  it 'finds many object matching search criteria' do
    users = User::Mapper.find(:name => 'Jane').to_a

    users.should have(2).items

    user1, user2 = users

    user1.should be_instance_of(User)
    user1.name.should eql('Jane')
    user1.age.should eql(21)

    user2.should be_instance_of(User)
    user2.age.should eql(22)
  end

  it 'finds and sorts objects' do
    users = User::Mapper.find(:name => 'Jane', :order => [ :age, :name, :id ]).to_a

    user1, user2 = users

    user1.should be_instance_of(User)
    user1.name.should eql('Jane')
    user1.age.should eql(21)

    user2.should be_instance_of(User)
    user1.name.should eql('Jane')
    user2.age.should eql(22)
  end

end
