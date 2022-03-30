# frozen_string_literal: true

require "rom/relation/name"

RSpec.describe ROM::Relation::Name, ".[]" do
  before { ROM::Relation::Name.cache.clear }

  it "returns a new name from args" do
    expect(ROM::Relation::Name[:users]).to eql(
      ROM::Relation::Name.new(:users)
    )

    expect(ROM::Relation::Name[:authors, :users]).to eql(
      ROM::Relation::Name.new(:authors, :users)
    )
  end

  it "raises when invalid arg was passed" do
    expect { ROM::Relation::Name[312] }.to raise_error(ArgumentError, "+312+ is not supported")
  end

  it "returns name object when it was passed in as arg" do
    name = ROM::Relation::Name[:users]
    expect(ROM::Relation::Name[name]).to be(name)
  end

  it "caches name instances" do
    name = ROM::Relation::Name[:users]
    expect(ROM::Relation::Name[:users]).to be(name)
  end
end
