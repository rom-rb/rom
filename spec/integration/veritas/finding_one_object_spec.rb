require 'spec_helper_integration'

describe 'Finding One Object' do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_user 1, 'John',  18
    insert_user 2, 'Jane',  21
    insert_user 3, 'Jane',  22
    insert_user 4, 'Piotr', 20

    user_mapper
  end

  it 'finds one object matching search criteria' do
    user = DM_ENV[user_model].one(:name => 'Jane', :age => 22)

    user.should be_instance_of(user_model)
    user.name.should eql('Jane')
    user.age.should eql(22)
  end

  it 'raises an exception if more than one objects were found' do
    expect { DM_ENV[user_model].one(:name => 'Jane') }.to raise_error(
      ManyTuplesError, "one tuple expected, but 2 were returned")
  end

end
