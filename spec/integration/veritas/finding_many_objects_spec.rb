require 'spec_helper_integration'

describe 'Finding Many Objects', :type => :integration do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_user 1, 'John',  23
    insert_user 2, 'Jane',  21
    insert_user 3, 'Jane',  22
    insert_user 4, 'Piotr', 20
    insert_user 5, 'Dan',   20

    insert_address 1, 1, 'Street 1/2', 'Chicago', '12345'
    insert_address 2, 5, 'Street 2/4', 'Boston',  '67890'

    user_mapper
    address_mapper
  end

  it 'finds many object matching search criteria' do
    users = DM_ENV[user_model].find(:name => 'Jane').to_a

    users.should have(2).items

    user1, user2 = users

    user1.should be_instance_of(user_model)
    user1.name.should eql('Jane')
    user1.age.should eql(21)

    user2.should be_instance_of(user_model)
    user2.age.should eql(22)
  end

  it 'finds and sorts objects' do
    users = DM_ENV[user_model].find(:name => 'Jane').order(:age, :name).to_a

    user1, user2 = users

    user1.should be_instance_of(user_model)
    user1.name.should eql('Jane')
    user1.age.should eql(21)

    user2.should be_instance_of(user_model)
    user1.name.should eql('Jane')
    user2.age.should eql(22)
  end

  it 'finds objects matching criteria from joined relation' do
    pending "Nested query conditions is not yet implemented"

    users = DM_ENV[user_model].find(:age => 20, :address => { :city => 'Boston' }).to_a

    users.should have(1).item

    user = users.first

    user.should be_instance_of(user_model)
    user.name.should eql('Dan')
    user.age.should eql(20)
  end

end
