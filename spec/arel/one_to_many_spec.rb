require 'spec_helper_integration'

describe '[Arel] One To Many with generated mapper' do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_user 1, 'John', 18
    insert_user 2, 'Jane', 21

    insert_order 1, 1, 'Apple'
    insert_order 2, 1, 'Apple'
    insert_order 3, 2, 'Peach'

    order_mapper

    user_mapper.has 0..n, :orders, order_model

    user_mapper.has 0..n, :apple_orders, order_model do
      where(source.right.first.left[:product].eq('Apple'))
    end
  end

  it 'loads associated orders' do
    user_order_mapper = DM_ENV[user_model].include(:orders)
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

  it 'loads associated orders where product = apple' do
    user_order_mapper = DM_ENV[user_model].include(:apple_orders)
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
