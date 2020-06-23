# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#combine" do
  let(:users) do
    ROM::Relation.new([], name: ROM::Relation::Name[:users])
  end

  let(:tasks) do
    ROM::Relation.new([], name: ROM::Relation::Name[:tasks])
  end

  let(:tags) do
    ROM::Relation.new([], name: ROM::Relation::Name[:tags])
  end

  let(:posts) do
    ROM::Relation.new([], name: ROM::Relation::Name[:posts])
  end

  let(:comments) do
    ROM::Relation.new([], name: ROM::Relation::Name[:comments])
  end

  let(:users_assocs_set) do
    {tasks: tasks_assoc, posts: posts_assoc}
  end

  let(:tasks_assocs_set) do
    {tags: tags_assoc}
  end

  let(:posts_assocs_set) do
    {comments: comments_assoc}
  end

  let(:tasks_assoc) do
    double(:tasks_assoc)
  end

  let(:tags_assoc) do
    double(:tags_assoc)
  end

  let(:posts_assoc) do
    double(:posts_assoc)
  end

  let(:comments_assoc) do
    double(:comments_assoc)
  end

  before do
    allow(users.schema).to receive(:associations).and_return(users_assocs_set)
    allow(tasks.schema).to receive(:associations).and_return(tasks_assocs_set)
    allow(posts.schema).to receive(:associations).and_return(posts_assocs_set)
  end

  context "with a list of assoc names" do
    it "returns a combined relation" do
      tasks_node = double(:tasks_node)

      expect(tasks_assoc).to receive(:node).and_return(tasks_node)
      expect(tasks_node).to receive(:eager_load).with(tasks_assoc).and_return(tasks)

      relation = users.combine(:tasks)

      expect(relation.root).to be(users)
      expect(relation.nodes).to eql([tasks])
    end

    it "allows combining the same assoc multiple times" do
      tasks_node = double(:tasks_node)

      expect(tasks_assoc).to receive(:node).and_return(tasks_node)
      expect(tasks_node).to receive(:eager_load).with(tasks_assoc).and_return(tasks)

      relation = users.combine(:tasks).combine(:tasks)

      expect(relation.root).to be(users)
      expect(relation.nodes).to eql([tasks])
    end
  end

  context "with a hash with nested assocs" do
    it "returns a combined relation" do
      tasks_node = double(:tasks_node)
      tags_node = double(:tags_node)

      expect(tasks_assoc).to receive(:node).and_return(tasks_node)
      expect(tasks_node).to receive(:eager_load).with(tasks_assoc).and_return(tasks)

      expect(tags_assoc).to receive(:node).and_return(tags_node)
      expect(tags_node).to receive(:eager_load).with(tags_assoc).and_return(tags)

      relation = users.combine(tasks: :tags)

      expect(relation.root).to be(users)
      expect(relation.nodes).to eql([tasks.combine(:tags)])
    end
  end

  context "with a hash with nested assocs as an array" do
    it "returns a combined relation" do
      tasks_node = double(:tasks_node)
      tags_node = double(:tags_node)

      expect(tasks_assoc).to receive(:node).and_return(tasks_node)
      expect(tasks_node).to receive(:eager_load).with(tasks_assoc).and_return(tasks)

      expect(tags_assoc).to receive(:node).and_return(tags_node)
      expect(tags_node).to receive(:eager_load).with(tags_assoc).and_return(tags)

      relation = users.combine(tasks: [:tags])

      expect(relation.root).to be(users)
      expect(relation.nodes).to eql([tasks.combine(:tags)])
    end
  end

  context "with a hash with two keys" do
    it "returns a combined relation" do
      tasks_node = double(:tasks_node)
      tags_node = double(:tags_node)
      posts_node = double(:posts_node)
      comments_node = double(:comments_node)

      expect(tasks_assoc).to receive(:node).and_return(tasks_node)
      expect(tasks_node).to receive(:eager_load).with(tasks_assoc).and_return(tasks)

      expect(tags_assoc).to receive(:node).and_return(tags_node)
      expect(tags_node).to receive(:eager_load).with(tags_assoc).and_return(tags)

      expect(posts_assoc).to receive(:node).and_return(posts_node)
      expect(posts_node).to receive(:eager_load).with(posts_assoc).and_return(posts)

      expect(comments_assoc).to receive(:node).and_return(comments_node)
      expect(comments_node).to receive(:eager_load).with(comments_assoc).and_return(comments)

      relation = users.combine(tasks: :tags, posts: :comments)

      expect(relation.root).to be(users)
      expect(relation.nodes).to eql([tasks.combine(:tags), posts.combine(:comments)])
    end
  end
end
