require 'spec_helper_integration'

describe 'Relationship - One To Many with generated mapper' do
  before(:all) do
    setup_db

    insert_user 1, 'John', 18
    insert_user 2, 'Jane', 21

    insert_order 1, 1, 'Apple'
    insert_order 2, 1, 'Apple'
    insert_order 3, 2, 'Peach'

    class Order
      attr_reader :id, :product

      def initialize(attributes)
        @id, @product = attributes.values_at(:id, :product)
      end
    end

    class User
      attr_reader :id, :name, :age, :orders, :apple_orders

      def initialize(attributes)
        @id, @name, @age, @orders, @apple_orders = attributes.values_at(
          :id, :name, :age, :orders, :apple_orders
        )
      end
    end

    class OrderMapper < DataMapper::Mapper::Relation

      model         Order
      relation_name :orders
      repository    :postgres

      map :id,      Integer, :key => true
      map :user_id, Integer
      map :product, String
    end

    class UserMapper < DataMapper::Mapper::Relation

      model         User
      relation_name :users
      repository    :postgres

      map :id,     Integer, :key => true
      map :name,   String,  :to => :username
      map :age,    Integer

      has 0..n, :orders, Order

      has 0..n, :apple_orders, Order do
        restrict { |r| r.orders_product.eq('Apple') }
      end
    end

  end

  it 'loads associated orders' do
    user_order_mapper = DataMapper[User].include(:orders)
    users_with_orders = user_order_mapper.to_a

    users_with_orders.should have(2).items

    user1, user2 = users_with_orders

    orders1 = user1.orders
    orders2 = user2.orders

    orders1.should have(2).items
    orders2.should have(1).items

    orders1[0].product.should eql('Apple')
    orders1[1].product.should eql('Apple')

    orders2[0].product.should eql('Peach')
  end

  it 'loads associated restricted apple orders' do
    user_order_mapper = DataMapper[User].include(:apple_orders)
    users_with_orders = user_order_mapper.to_a

    users_with_orders.should have(1).item

    user   = users_with_orders.first
    orders = user.apple_orders

    orders.should have(2).items

    order1, order2 = orders

    order1.product.should eql('Apple')
    order2.product.should eql('Apple')
  end
end
