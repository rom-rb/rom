require 'spec_helper_integration'

describe "Inserting new objects with ARel" do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_user 1, 'John', 20

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

  it "updates existing object" do
    mapper = DM_ENV[user_model]
    user   = mapper.first

    user.age = 21

    expect(mapper.update(user, :age)).to be(1)
    expect(mapper.first.age).to be(21)
  end
end
