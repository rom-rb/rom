# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#adapter" do
  it "returns adapter inferred from parent class" do
    module Test
      class Users < ROM::Relation[:memory]
      end
    end

    relation = Test::Users.new

    expect(relation.adapter).to be(:memory)
  end
end
