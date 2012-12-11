require 'spec_helper_integration'

describe "Inserting new objects with ARel" do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

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

    user = user_model.new(:name => 'Piotr', :age => 29)
    mapper.insert(user)

    user = mapper.first

    user.should be_instance_of(user_model)
    user.id.should be(1)
    user.name.should eql('Piotr')
    user.age.should be(29)
  end
end
