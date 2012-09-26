require 'spec_helper_integration'

describe "Generated mapper from model definition" do
  before do
    class User
      include DataMapper::Model

      attribute :id,   Integer
      attribute :name, String
      attribute :age,  Integer
    end
  end

  it "generates mapper for the model" do
    mapper = DataMapper.generate_mapper_for(User) do
      key :id
      map :name, :to => :username
    end

    mapper.attributes[:id].key?.should be(true)
    mapper.attributes[:name].field.should be(:username)
  end
end
