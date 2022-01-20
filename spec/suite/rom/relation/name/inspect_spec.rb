# frozen_string_literal: true

require "rom/relation/name"

RSpec.describe ROM::Relation::Name, "#inspect" do
  it "provides relation name" do
    name = ROM::Relation::Name.new(:users)
    expect(name.inspect).to eql("ROM::Relation::Name(users)")

    name = ROM::Relation::Name.new(:users, :users, :users)
    expect(name.inspect).to eql("ROM::Relation::Name(users)")
  end

  it "provides dataset and relation names" do
    name = ROM::Relation::Name.new(:authors, :users)
    expect(name.inspect).to eql("ROM::Relation::Name(authors on users)")
  end

  it "provides dataset, relation and alias names" do
    name = ROM::Relation::Name.new(:authors, :users, :admins)
    expect(name.inspect).to eql("ROM::Relation::Name(authors on users as admins)")
  end
end
