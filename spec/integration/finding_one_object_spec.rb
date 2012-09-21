require 'spec_helper_integration'

describe 'Finding One Object' do
  before(:all) do
    setup_db

    insert_user 1, 'John',  18
    insert_user 2, 'Jane',  21
    insert_user 3, 'Jane',  22
    insert_user 4, 'Piotr', 20

    class User
      attr_reader :id, :name, :age

      def initialize(attributes)
        @id, @name, @age = attributes.values_at(:id, :name, :age)
      end

      class Mapper < DataMapper::Mapper::Relation::Base

        model         User
        relation_name :users
        repository    :postgres

        map :id,   Integer, :key => true
        map :name, String,  :to  => :username
        map :age,  Integer
      end
    end
  end

  it 'finds one object matching search criteria' do
    user = DataMapper[User].one(:name => 'Jane', :age => 22)

    user.should be_instance_of(User)
    user.name.should eql('Jane')
    user.age.should eql(22)
  end

  it 'raises an exception if more than one objects were found' do
    expect { DataMapper[User].one(:name => 'Jane') }.to raise_error(
      "#{DataMapper[User]}.one returned more than one result")
  end

end
