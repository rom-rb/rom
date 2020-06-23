# frozen_string_literal: true

require "rom/relation/combined"

RSpec.describe ROM::Relation::Combined, "#map_with" do
  subject(:relation) do
    ROM::Relation::Combined.new(users, [tasks.to_node(:tasks, type: :many, keys: {id: :user_id}).for_users])
  end

  let(:users) do
    ROM::Relation.new([{id: 1, name: "Jane"}, {id: 2, name: "John"}], mappers: mapper_registry)
  end

  let(:tasks) do
    Class.new(ROM::Relation) do
      def for_users(users)
        new(dataset.select { |t| users.pluck(:id).include?(t[:user_id]) })
      end

      def to_node(_name, type:, keys:)
        with(meta: {combine_name: :tasks, combine_type: type, keys: keys})
      end
    end.new([{user_id: 2, title: "John's Task"}, {user_id: 1, title: "Jane's Task"}])
  end

  let(:mapper_registry) { ROM::MapperRegistry.build(mappers) }

  let(:mappers) do
    {task_list: lambda { |users|
                  users.map do |u|
                    h = u.merge(task_list: u[:tasks].map { |t| t[:title] })
                    h.delete(:tasks)
                    h
                  end
                }}
  end

  it "returns a new graph with custom model" do
    expect(relation.map_with(:task_list).to_a)
      .to eql([
        {id: 1, name: "Jane", task_list: ["Jane's Task"]},
        {id: 2, name: "John", task_list: ["John's Task"]}
      ])
  end
end
