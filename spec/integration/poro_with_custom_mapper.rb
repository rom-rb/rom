require 'spec_helper'

describe 'PORO with a custom mapper' do
  before(:all) do
    setup_db

    insert_user 1, 'John'
    insert_user 2, 'Jane'
  end

  let(:relation) do
    DataMapper.relation_registry << User::Mapper.base_relation
    Veritas::Relation::Gateway.new(DATABASE_ADAPTER, DataMapper.relation_registry[:users])
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
      name :users
    end
  end

  it 'finds all users' do
    user = User::Mapper.new(relation).first

    user.should be_instance_of(User)
  end

  it 'finds users matching name' do
    user = User::Mapper.new(relation.restrict { |r| r.username.eq('John') }).first

    user.should be_instance_of(User)
    user.name.should eql('John')
  end
end
