# frozen_string_literal: true

require "rom/memory"

RSpec.describe ROM::Relation, "#[]" do
  it "defines a canonical schema for a relation" do
    class Test::Users < ROM::Relation[:memory]
      schema do
        attribute :id, Types::Integer
        attribute :name, Types::String
      end
    end

    relation = Test::Users.new([])

    expect(relation[:id]).to be(relation.schema[:id])
    expect(relation[:name]).to be(relation.schema[:name])
  end
end
