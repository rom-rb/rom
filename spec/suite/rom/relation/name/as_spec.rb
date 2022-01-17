# frozen_string_literal: true

require "rom/relation/name"

RSpec.describe ROM::Relation::Name, "#as" do
  it "returns an aliased name" do
    name = ROM::Relation::Name[:users]
    expect(name.as(:people)).to be(ROM::Relation::Name[:users, :users, :people])
  end
end
