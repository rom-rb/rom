require 'rom/schema'

RSpec.describe ROM::Schema, '#wrap' do
  subject(:schema) do
    define_schema(:users, id: ROM::Types::Int, name: ROM::Types::String)
  end

  let(:wrapped) do
    schema.wrap(:users)
  end

  it 'returns projected schema with renamed attributes using provided prefix' do
    expect(wrapped.map(&:alias)).to eql(%i[users_id users_name])
    expect(wrapped.map { |attr| attr.meta[:name] }).to eql(%i[id name])
    expect(wrapped.all?(&:wrapped?)).to be(true)
  end
end
