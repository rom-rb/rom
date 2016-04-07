RSpec.describe 'struct builder', '#call' do
  subject(:builder) { ROM::Repository::StructBuilder.new }

  let(:input) { [:users, [:header, [[:attribute, :id], [:attribute, :name]]]] }

  before { builder[*input] }

  it 'generates a struct for a given relation name and columns' do
    struct = builder.registry[input.hash]

    user = struct.new(id: 1, name: 'Jane')

    expect(user.id).to be(1)
    expect(user.name).to eql('Jane')

    expect(user[:id]).to be(1)
    expect(user[:name]).to eql('Jane')

    expect(Hash[user]).to eql(id: 1, name: 'Jane')
  end

  it 'stores struct in the registry' do
    expect(builder.registry[input.hash]).to be(builder[*input])
  end
end
