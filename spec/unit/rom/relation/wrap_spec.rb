# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#wrap" do
  let(:users) do
    ROM::Relation.new([], name: ROM::Relation::Name[:users])
  end

  let(:tasks) do
    ROM::Relation.new([], name: ROM::Relation::Name[:tasks])
  end

  let(:users_assocs_set) do
    {tasks: tasks_assoc}
  end

  let(:tasks_assoc) do
    double(:tasks_assoc)
  end

  before do
    allow(users.schema).to receive(:associations).and_return(users_assocs_set)
  end

  context "with a list of assoc names" do
    it "returns a wrap relation" do
      tasks_node = double(:tasks_node)

      expect(tasks_assoc).to receive(:wrap).and_return(tasks_node)

      relation = users.wrap(:tasks)

      expect(relation.root).to be(users)
      expect(relation.nodes).to eql([tasks_node])
    end
  end
end
