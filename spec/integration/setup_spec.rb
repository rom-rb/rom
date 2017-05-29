require 'rom/memory'

RSpec.describe 'Setting up rom suite' do
  subject(:rom) do
    ROM.container(:memory) do |config|
      config.register_relation(Test::Users)
    end
  end

  before do
    class Test::Users < ROM::Relation[:memory]
      schema(:users) do
        attribute :id, Types::Int
        attribute :name, Types::String
      end
    end
  end

  it "works" do
    expect(rom.relations[:users]).to be_instance_of(Test::Users)
  end
end
