require 'spec_helper_integration'

describe 'Relationship - Many To One with generated mapper' do
  include_context 'Models and Mappers'

  subject { DM_ENV[address_model].include(:user).all }

  before(:all) do
    setup_db

    insert_user 1, 'John', 18
    insert_user 2, 'Jane', 21

    insert_address 1, 1, 'Street 1/2', 'Chicago', '12345'
    insert_address 2, 2, 'Street 2/4', 'Boston',  '67890'

    user_mapper
    address_mapper.belongs_to :user, user_model
  end

  let(:address_1) {
    address_model.new(
      {
        :id      => 1,
        :user_id => 1,
        :user    => user_model.new({ :id => 1, :name => 'John', :age => 18 }),
        :street  => 'Street 1/2',
        :city    => 'Chicago',
        :zipcode => '12345'
      }
    )
  }

  let(:address_2) {
    address_model.new(
      {
        :id      => 2,
        :user_id => 2,
        :user    => user_model.new({ :id => 2, :name => 'Jane', :age => 21 }),
        :street  => 'Street 2/4',
        :city    => 'Boston',
        :zipcode => '67890'
      }
    )
  }

  it { should include(address_1) }
  it { should include(address_2) }

  its(:size) { should == 2 }
end
