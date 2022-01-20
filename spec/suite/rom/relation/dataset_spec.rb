# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#dataset" do
  it "returns dataset inferred from gateway" do
    module Test
      class Users < ROM::Relation[:memory]
      end
    end

    relation = Test::Users.new

    expect(relation.dataset).to be_empty
  end
end
