# frozen_string_literal: true

require "rom/relation/name"

RSpec.describe ROM::Relation::Name, "#eql?" do
  it "returns true when relation is the same" do
    expect(ROM::Relation::Name.new(:users))
      .to eql(ROM::Relation::Name.new(:users))
  end

  it "returns false when relation is not the same" do
    expect(ROM::Relation::Name.new(:users))
      .to_not eql(ROM::Relation::Name.new(:tasks))
  end

  it "returns true when relation and dataset are the same" do
    expect(ROM::Relation::Name.new(:users, :people))
      .to eql(ROM::Relation::Name.new(:users, :people))
  end

  it "returns false when relation and dataset are not the same" do
    expect(ROM::Relation::Name.new(:users, :people))
      .to_not eql(ROM::Relation::Name.new(:users, :folks))
  end

  it "returns true when relation, dataset and alias are the same" do
    expect(ROM::Relation::Name.new(:posts, :posts, :published))
      .to eql(ROM::Relation::Name.new(:posts, :posts, :published))
  end

  it "returns false when relation, dataset and alias are not the same" do
    expect(ROM::Relation::Name.new(:posts, :articles, :published))
      .to_not eql(ROM::Relation::Name.new(:posts, :posts, :deleted))
  end

  it "returns false when relation and dataset are the same but aliases are different" do
    expect(ROM::Relation::Name.new(:posts, :posts, :published))
      .to_not eql(ROM::Relation::Name.new(:posts, :posts, :deleted))
  end
end
