# frozen_string_literal: true

require "rom/relation/name"

RSpec.describe ROM::Relation::Name, "#to_sym" do
  it "returns relation name" do
    expect(ROM::Relation::Name.new(:users).to_sym).to be(:users)
    expect(ROM::Relation::Name.new(:authors, :users).to_sym).to be(:authors)
  end
end
