require 'spec_helper_integration'

describe 'Relationship - One To One - Explicit Loading' do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_user 1, 'John',  18
    insert_user 2, 'Jane',  21
    insert_user 3, 'Piotr', 29

    insert_address 1, 3, 'Street 1/2', 'Krakow',  '12345'
    insert_address 2, 2, 'Street 1/2', 'Chicago', '54321'
    insert_address 3, 1, 'Street 2/4', 'Boston',  '67890'

    address_mapper
    user_mapper
  end

  it 'loads parent and then child' do
    pending "AxiomRelation#rename is not finished yet"

    user    = user_mapper.to_a.last
    address = DM_ENV[address_mapper].join(user_mapper.rename(:id => :user_id)).first

    address.should be_instance_of(address_model)
    address.id.should eql(1)
    address.city.should eql('Krakow')
  end
end
