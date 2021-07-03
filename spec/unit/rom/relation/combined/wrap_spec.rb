# frozen_string_literal: true

require "rom/relation/combined"

RSpec.describe ROM::Relation::Combined, "#wrap" do
  subject(:relation) do
    ROM::Relation::Combined.new(users, [tasks])
  end

  let(:users) do
    ROM::Relation.new([])
  end

  let(:tasks) do
    ROM::Relation.new([])
  end

  let(:posts) do
    ROM::Relation.new([])
  end

  it "returns a new graph with new root as a wrap relation" do
    posts_assoc = double(:posts_assoc)

    allow(users).to receive(:associations).and_return(posts: posts_assoc)

    expect(posts_assoc).to receive(:wrap).and_return(posts)

    new_graph = relation.wrap(:posts)

    expect(new_graph.root).to be_wrap
    expect(new_graph.nodes).to eql(relation.nodes)
  end
end
