require 'spec_helper_integration'

describe 'Relationship - One To One with generated mapper' do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_user 1, 'John',  18
    insert_user 2, 'Jane',  21
    insert_user 3, 'Piotr', 29

    insert_address 1, 3, 'Street 1/2', 'Krakow',  '12345'
    insert_address 2, 2, 'Street 1/2', 'Chicago', '54321'
    insert_address 3, 1, 'Street 2/4', 'Boston',  '67890'

    user_mapper.has 1, :address, address_model
    user_mapper.has 1, :home_address, address_model do
      restrict { |r| r.addresses_city.eq('Krakow') }
    end

    address_mapper.belongs_to :user, user_model
  end

  it 'loads the object without association' do
    user = DM_ENV[user_model].all.first

    user.should be_instance_of(user_model)
    user.id.should eql(1)
    user.name.should eql('John')
    user.age.should eql(18)
  end

  it 'loads associated object' do
    mapper  = DM_ENV[user_model].include(:address)
    user    = mapper.all.last
    address = user.address

    address.should be_instance_of(address_model)
    address.id.should eql(3)
    address.city.should eql('Boston')
  end

  it 'loads restricted association' do
    mapper  = DM_ENV[user_model].include(:home_address)
    address = mapper.to_a.first.home_address

    address.should be_instance_of(address_model)
    address.id.should eql(1)
    address.city.should eql('Krakow')
  end

  it 'finds users with matching address' do
    user_address_mapper = DM_ENV[user_model].include(:address)
    users               = user_address_mapper.restrict { |r| r.addresses_city.eq('Krakow') }.to_a

    users.should have(1).item

    user = users.first

    user.name.should eql('Piotr')
    user.address.id.should eql(1)
    user.address.city.should eql('Krakow')
  end

  it 'finds users with matching address using mapper query API' do
    pending "Query doesn't support nested conditions"

    users = user_mapper.include(:address).find(:address => { :city => "Krakow" })

    users.should have(1).item

    user = users.first

    user.name.should eql('Piotr')
    user.address.id.should eql(1)
    user.address.city.should eql('Krakow')
  end
end
