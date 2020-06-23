# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#preload_assoc" do
  subject(:users) do
    ROM::Relation.new([], name: ROM::Relation::Name[:users])
  end

  let(:tasks) do
    ROM::Relation.new([], name: ROM::Relation::Name[:tasks])
  end

  let(:assoc) do
    double(:assoc)
  end

  it "is auto-curried" do
    expect(users.preload_assoc(assoc)).to be_curried
  end

  it "returns preloaded relation by association" do
    expect(assoc).to receive(:preload).with(users, tasks).and_return([])

    expect(users.preload_assoc(assoc, tasks)).to eql([])
  end
end
