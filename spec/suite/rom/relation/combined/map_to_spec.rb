# frozen_string_literal: true

require "rom/relation/combined"

RSpec.describe ROM::Relation::Combined, "#map_to" do
  subject(:relation) do
    ROM::Relation::Combined.new(users, [tasks.for_users])
  end

  let(:users) do
    Class.new(ROM::Relation) do
      config.auto_map = false
    end.new([{id: 1, name: "Jane"}, {id: 2, name: "John"}])
  end

  let(:tasks) do
    Class.new(ROM::Relation) do
      config.auto_map = false

      def for_users(users)
        dataset.select { |t| users.pluck(:id).include?(t[:user_id]) }
      end
    end.new([{user_id: 2, title: "John's Task"}, {user_id: 1, name: "Jane's Task"}])
  end

  let(:model) do
    Class.new
  end

  it "returns a new graph with custom model" do
    expect(relation.map_to(model).meta[:model]).to be(model)
  end

  it "maintains nodes" do
    expect(relation.map_to(model).nodes).to eql(relation.nodes)
  end
end
