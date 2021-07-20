# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#map_to" do
  subject(:relation) do
    ROM::Relation.new([], name: ROM::Relation::Name[:users])
  end

  it "returns a new relation with an aliased name" do
    expect(relation.as(:people).name).to eql(ROM::Relation::Name[:users].as(:people))
  end
end
