# frozen_string_literal: true

require 'rom/types'
require 'rom/attribute'

RSpec.describe ROM::Attribute, '#optional' do
  subject(:attribute) do
    ROM::Attribute.new(ROM::Types::Integer, name: :id).meta(read: ROM::Types::Coercible::Integer)
  end

  it 'transforms read type' do
    expect(attribute.optional.to_read_type['1']).to eql(1)
    expect(attribute.optional.to_read_type[nil]).to be_nil
  end
end
