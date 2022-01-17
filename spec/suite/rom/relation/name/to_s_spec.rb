# frozen_string_literal: true

require "rom/relation/name"

RSpec.describe ROM::Relation::Name, "#to_s" do
  it "returns stringified relation name" do
    expect(ROM::Relation::Name.new(:users).to_s).to eql("users")
    expect(ROM::Relation::Name.new(:authors, :users).to_s).to eql("authors on users")
  end
end
