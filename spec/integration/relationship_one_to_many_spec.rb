require 'spec_helper_integration'

describe 'Relationship - Onet To Many' do
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

    class OrderMapper < DataMapper::Mapper::VeritasMapper
      map :id,      :type => Integer, :key => true
      map :product, :type => String

      model         Order
      relation_name :orders
      repository    :postgres
    end

    class UserOrderMapper < DataMapper::Mapper::VeritasMapper
      map :id,     :type => Integer, :to => :user_id, :key => true
      map :name,   :type => String,  :to => :username
      map :age,    :type => Integer
      map :orders, :type => Order, :collection => true

      model User
    end

    class UserMapper < DataMapper::Mapper::VeritasMapper
      map :id,     :type => Integer, :key => true
      map :name,   :type => String,  :to => :username
      map :age,    :type => Integer

      has_many :orders, :mapper => UserOrderMapper do |orders|
        rename(:id => :user_id).join(orders)
      end

      model         User
      relation_name :users
      repository    :postgres
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
