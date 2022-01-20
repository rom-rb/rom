# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#eager_load" do
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
    double(:tasks_assoc, override?: override)
  end

  before do
    allow(users.schema).to receive(:associations).and_return(users_assocs_set)
  end

  context "when assocs is not set to override default view" do
    let(:override) { false }

    # TODO: rewrite this so that it doesn't mock
    xit "returns an curried relation for eager loading" do
      expect(tasks_assoc).to receive(:prepare).with(users).and_return(tasks)

      relation = users.eager_load(tasks_assoc)

      expect(relation).to be_curried
      expect(relation.relation).to be(tasks)
    end
  end

  context "when assocs is set to override default view" do
    let(:override) { true }

    # TODO: rewrite this so that it doesn't mock
    xit "returns an curried relation for eager loading" do
      expect(tasks_assoc).to receive(:prepare).with(users).and_return(tasks)
      expect(tasks).to receive(:call).with(tasks_assoc).and_return(tasks)

      relation = users.eager_load(tasks_assoc)

      expect(relation).to be(tasks)
    end
  end
end
