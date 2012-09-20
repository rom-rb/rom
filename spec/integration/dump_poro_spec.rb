require 'spec_helper_integration'

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
        map :id,   Integer, :key => true
        map :name, String,  :to  => :username
        map :age,  Integer

        model         User
        relation_name :users
        repository    :postgres
      end
    end
  end

  let(:mapper) { DataMapper[User] }

  it 'dumps a poro object' do
    user = mapper.first
    mapper.dump(user).should eql({ :id => 1, :username => 'John', :age => 18 })
  end
end
