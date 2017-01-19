require 'rom/schema'

RSpec.describe ROM::Schema, '#append' do
  subject(:schema) { left.append(*right) }

  let(:left) do
    define_schema(:users, id: :Int, name: :String)
  end

  let(:right) do
    define_schema(:tasks, user_id: :Int)
  end

  it 'returns a new schema with attributes from two schemas' do
    expect(schema.map(&:name)).to eql(%i[id name user_id])
  end
end
