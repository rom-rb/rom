require 'rom/schema'

RSpec.describe ROM::Schema, '#merge' do
  subject(:schema) { left.merge(right) }

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
