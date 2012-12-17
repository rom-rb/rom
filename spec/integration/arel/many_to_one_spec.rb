require 'spec_helper_integration'

describe '[Arel] Many To One with generated mapper' do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_user 1, 'John', 18
    insert_user 2, 'Jane', 21

    insert_address 1, 1, 'Street 1/2', 'Chicago', '12345'
    insert_address 2, 2, 'Street 2/4', 'Boston',  '67890'

    user_mapper
    address_mapper.belongs_to :user, user_model
  end

  it 'loads associated object' do
    mapper  = DM_ENV[address_model].include(:user)
    address = mapper.first
    user    = DM_ENV[user_model].first

    address.user.should be_instance_of(user_model)
    address.user.id.should eql(user.id)
  end
end
