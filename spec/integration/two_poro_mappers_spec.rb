require 'spec_helper'

describe 'Two PORO mappers' do
  before(:all) do
    setup_db

    insert_user 1, 'John', 18
    insert_user 2, 'Jane', 21

    insert_address 1, 1, 'Street 1/2', 'Chicago', '12345'
    insert_address 2, 2, 'Street 2/4', 'Boston',  '67890'

    DataMapper.relation_registry << Veritas::Relation::Gateway.new(
      DATABASE_ADAPTER, Address::Mapper.base_relation)

    DataMapper.relation_registry << Veritas::Relation::Gateway.new(
      DATABASE_ADAPTER, User::Mapper.base_relation)
  end

  let(:operation) do
    left  = DataMapper.relation_registry[:users]
    right = DataMapper.relation_registry[:addresses].restrict { |r| r.city.eq('Boston') }

    left.join(right)
  end

  class Address
    attr_reader :id, :street, :zipcode, :city

    def initialize(attributes)
      @id, @street, @zipcode, @city = attributes.values_at(:id, :name, :zipcode, :city)
    end

    class Mapper < DataMapper::Mapper::VeritasMapper
      map :id,      :type => Integer
      map :user_id, :type => Integer
      map :street,  :type => String
      map :zipcode, :type => String
      map :city,    :type => String

      model Address
      relation_name :addresses
    end
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

      model User
      relation_name :users
    end
  end

  it 'finds user with a specific address' do
    pending 'this does not work yet'

    users = User::Mapper.new(operation.restrict { |r| r.city.eq('Boston') }.optimize).to_a
    user  = users.first

    users.should have(1).item

    user.should be_instance_of(User)
    user.name.should eql('Jane')
  end

end
