# frozen_string_literal: true

require "rom/types"
require "rom/attribute"

RSpec.describe ROM::Attribute, "#to_ast" do
  subject(:attribute) { ROM::Attribute.new(ROM::Types::Integer, name: :id) }

  types = [
    ROM::Types::Integer,
    ROM::Types::Strict::Integer,
    ROM::Types::Strict::Integer.optional
  ]

  to_attr = -> type { ROM::Attribute.new(type, name: :id) }

  types.each do |type|
    specify do
      expect(
        to_attr.(type).to_ast
      ).to eql([:attribute, [:id, type.to_ast, alias: nil]])
    end
  end

  example "wrapped type" do
    expect(attribute.wrapped(:users).to_ast)
      .to eql([:attribute, [:id, ROM::Types::Integer.to_ast,
                            wrapped: true, alias: :users_id]])
  end
end
