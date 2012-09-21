require 'spec_helper_integration'

describe 'Relationship - One To Many' do
  before(:all) do
    setup_db

    insert_user 1, 'John', 18
    insert_user 2, 'Jane', 21

    insert_order 1, 1, 'Apple'
    insert_order 2, 1, 'Orange'
    insert_order 3, 2, 'Peach'

    class Order
      attr_reader :id, :product

      def initialize(attributes)
        @id, @product = attributes.values_at(:id, :product)
      end
    end

    class User
      attr_reader :id, :name, :age, :orders

      def initialize(attributes)
        @id, @name, @age, @orders = attributes.values_at(:id, :name, :age, :orders)
      end
    end

    class OrderMapper < DataMapper::Mapper::Relation::Base

      model         Order
      relation_name :orders
      repository    :postgres

      map :id,      Integer, :key => true
      map :product, String
    end

    class UserOrderMapper < DataMapper::Mapper::Relation

      model User

      map :id,     Integer, :to => :user_id, :key => true
      map :name,   String,  :to => :username
      map :age,    Integer
      map :orders, Order, :collection => true
    end

    class UserMapper < DataMapper::Mapper::Relation::Base

      model         User
      relation_name :users
      repository    :postgres

      map :id,     Integer, :key => true
      map :name,   String,  :to => :username
      map :age,    Integer

      has n, :orders, :mapper => UserOrderMapper do |orders|
        rename(:id => :user_id).join(orders)
      end
    end

  end

  it 'loads associated objects' do
    user_order_mapper = DataMapper[User].include(:orders)
    users_with_orders = user_order_mapper.to_a

    users_with_orders.should have(2).items

    user1, user2 = users_with_orders

    orders1 = user1.orders
    orders2 = user2.orders

    orders1.should have(2).item
    orders2.should have(1).items

    orders1[0].product.should eql('Apple')
    orders1[1].product.should eql('Orange')

    orders2[0].product.should eql('Peach')
  end
end
