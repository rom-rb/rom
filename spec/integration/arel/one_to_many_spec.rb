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

    user_mapper.has 0..n, :apple_orders, order_model do |source, target|
      source.where(target[:product].eq('Apple'))
    end
  end

  it 'loads users without orders' do
    mapper = DM_ENV[user_model]

    users = mapper.all

    expect(users).to have(2).items

    user1, user2 = users

    expect(user1.id).to eql('1')
    expect(user1.name).to eql('John')
    expect(user1.age).to eql('18')

    expect(user2.id).to eql('2')
    expect(user2.name).to eql('Jane')
    expect(user2.age).to eql('21')
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
