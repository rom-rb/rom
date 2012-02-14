require 'spec_helper'

describe 'PORO with a custom mapper' do
  before(:all) do
    setup_db

    insert_user 1, 'John'
    insert_user 2, 'Jane'
  end

  class User
    attr_reader :id, :name

    def initialize(attributes)
      @id, @name = attributes.values_at(:id, :name)
    end

    class Mapper < DataMapper::Mapper::VeritasMapper
      map :id, :type => Integer
      map :name, :to => :username, :type => String

      model User
      name 'users'
    end
  end

  it 'finds all users' do
    mapper = User::Mapper.find
    users  = mapper.to_a
    user   = users.first

    user.should be_instance_of(User)
  end

  it 'finds users matching name' do
    mapper = User::Mapper.find(:name => 'John')
    users  = mapper.to_a
    user   = users.first

    user.should be_instance_of(User)
    user.name.should eql('John')
  end
end
