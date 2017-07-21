require 'rom/types'
require 'rom/attribute'

RSpec.describe ROM::Attribute, '#optional' do
  subject(:attribute) do
    ROM::Attribute.new(ROM::Types::Int).meta(read: ROM::Types::Coercible::Int)
  end

  it 'transforms read type' do
    expect(attribute.optional.to_read_type['1']).to eql(1)
    expect(attribute.optional.to_read_type[nil]).to be_nil
  end
end
