# frozen_string_literal: true

require 'rom/schema'

RSpec.describe ROM::Schema, '#key?' do
  subject(:schema) do
    define_schema(:users, name: :String)
  end

  it 'returns true when an attribute exists' do
    expect(schema.key?(:name)).to be(true)
  end

  it 'returns false when an attribute does not exist' do
    expect(schema.key?(:foo)).to be(false)
  end
end
