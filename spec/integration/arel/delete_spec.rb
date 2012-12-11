require 'spec_helper_integration'

describe "Deleting objects with ARel" do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_user 1, 'John',  18
    insert_user 2, 'Jane',  21
    insert_user 3, 'Piotr', 29

    user_mapper
  end

  let(:user_model) {
    mock_model('User') {
      include DataMapper::Model

      attribute :id,   Integer, :key => true
      attribute :name, String
      attribute :age,  Integer
    }
  }

  it "actually works ZOMG" do
    mapper = DM_ENV[user_model]
    user   = mapper.first

    mapper.delete(user)

    mapper.to_a.map(&:id).should_not include(1)
  end
end
