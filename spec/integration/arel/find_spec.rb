require 'spec_helper_integration'

describe "[arel] Finding objects" do
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

  context "without a block" do
    it "returns restricted objects" do
      users = DM_ENV[user_model].find(:name => 'Jane', :age => 21).all

      users.should have(1).items

      user = users.first

      user.name.should eql('Jane')
      user.age.should be(21)
    end
  end

  context "with a block" do
    it "yields relation" do
      users = DM_ENV[user_model].find(:name => 'Jane') { |relation|
        relation.where(relation[:age].gte(21))
      }.all

      users.should have(1).items

      user = users.first

      user.name.should eql('Jane')
      user.age.should be(21)
    end
  end
end
