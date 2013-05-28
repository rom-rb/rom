require 'spec_helper_integration'

describe 'Relationship - One To Many with generated mapper' do
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
      restrict { |r| r.product.eq('Apple') }
    end
  end
  let(:order1) { order_model.new(:id => 1, :product => 'Apple', :user_id => 1) }
  let(:order2) { order_model.new(:id => 2, :product => 'Apple', :user_id => 1) }
  let(:order3) { order_model.new(:id => 3, :product => 'Peach', :user_id => 2) }

  it 'loads associated orders' do
    user_order_mapper = DM_ENV[user_model].include(:orders)
    users_with_orders = user_order_mapper.to_a

    users_with_orders.should have(2).items

    user1, user2 = users_with_orders.sort_by(&:id)

    orders1 = user1.orders
    orders2 = user2.orders

    orders1.should have(2).items
    orders2.should have(1).items

    orders1.should =~ [order1, order2]

    orders2.should =~ [order3]
  end

  it 'loads associated restricted apple orders' do
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
