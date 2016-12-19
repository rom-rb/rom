require 'rom/schema'

RSpec.describe ROM::Schema, '#rename' do
  subject(:schema) do
    define_schema(:users, user_id: ROM::Types::Int, user_name: ROM::Types::String)
  end

  let(:renamed) do
    schema.rename(user_id: :id, user_name: :name)
  end

  it 'returns projected schema with renamed attributes' do
    expect(renamed.map(&:name)).to eql(%i[id name])
    expect(renamed.map { |attr| attr.meta[:name] }).to eql(%i[user_id user_name])
  end
end
