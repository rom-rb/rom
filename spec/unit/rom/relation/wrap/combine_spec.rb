# frozen_string_literal: true

require "rom/relation/wrap"

RSpec.describe ROM::Relation::Wrap, "#combine" do
  subject(:relation) do
    ROM::Relation::Wrap.new(users, [tasks])
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

  it "returns a new wrap with new root as a graph relation" do
    posts_assoc = double(:posts_assoc, override?: false)
    allow(users).to receive(:associations).and_return(posts: posts_assoc)

    expect(posts_assoc).to receive(:prepare).and_return(posts)
    expect(posts_assoc).to receive(:node).and_return(posts)

    new_graph = relation.combine(:posts)

    expect(new_graph.root).to be_graph
    expect(new_graph.nodes).to eql(relation.nodes)
  end
end
