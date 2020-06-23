# frozen_string_literal: true

RSpec.describe ROM::Relation::Combined do
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

  describe "#with_nodes" do
    it "returns a new graph with new nodes" do
      new_graph = relation.with_nodes([posts])

      expect(new_graph.nodes[0]).to eql(posts)
    end
  end
end
