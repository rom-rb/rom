require 'spec_helper'

describe 'Dump a PORO' do
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
      end
    end
  end

  let(:relation) do
    DataMapper.relation_registry << User::Mapper.base_relation
    Veritas::Relation::Gateway.new(DATABASE_ADAPTER, DataMapper.relation_registry[:users])
  end

  it 'dumps a poro object' do
    mapper = User::Mapper.new(relation)
    user   = mapper.first

    mapper.dump(user).should eql({ :id => 1, :username => 'John', :age => 18 })
  end
end
