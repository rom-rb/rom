require 'rom/types'
require 'rom/attribute'

RSpec.describe ROM::Attribute, '#to_ast' do
  subject(:attribute) { ROM::Attribute.new(ROM::Types::Int).meta(name: :id) }

  types = [
    ROM::Types::Int,
    ROM::Types::Strict::Int,
    ROM::Types::Strict::Int.optional
  ]

  to_attr = -> type { ROM::Attribute.new(type).meta(name: :id) }

  types.each do |type|
    specify do
      expect(to_attr.(type).to_ast).to eql([:attribute, [:id, type.to_ast, {}]])
    end
  end

  example 'wrapped type' do
    expect(attribute.wrapped(:users).to_ast).
      to eql([:attribute, [:id, ROM::Types::Int.to_ast,
                           wrapped: true, alias: :users_id]])
  end
end
