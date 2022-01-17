# frozen_string_literal: true

require "rom/relation/combined"

RSpec.describe ROM::Relation::Combined, "#command" do
  subject(:relation) do
    ROM::Relation::Combined.new(users, [tasks])
  end

  let(:users) do
    ROM::Relation.new([])
  end

  let(:tasks) do
    ROM::Relation.new([])
  end

  it "raises when type is not :create" do
    expect { relation.command(:update) }
      .to raise_error(
        NotImplementedError,
        "ROM::Relation::Combined#command doesn't work with :update command type yet"
      )
  end
end
