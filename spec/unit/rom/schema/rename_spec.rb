require 'rom/schema'

RSpec.describe ROM::Schema, '#rename' do
  subject(:schema) do
    define_schema(:users, user_id: ROM::Types::Int, user_name: ROM::Types::String, user_email: ROM::Types::String)
  end

  let(:renamed) do
    schema.rename(user_id: :id, user_name: :name)
  end

  it 'returns projected schema with renamed attributes' do
    expect(renamed.map(&:name)).to eql(%i[user_id user_name user_email])
    expect(renamed.map(&:alias)).to eql([:id, :name, nil])
    expect(renamed.all?(&:aliased?)).to be(false)
    expect(renamed[:id]).to be_aliased
    expect(renamed[:name]).to be_aliased
  end
end
