# frozen_string_literal: true

RSpec.describe ROM::Relation::Combined, "#to_a" do
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

  it "coerces to an array" do
    expect(relation.to_a).to match_array([users.call, [tasks.for_users(users.call)]])
  end

  it "returns empty arrays when left was empty" do
    empty_users = users.new([])

    expect(relation.new([]).to_a)
      .to eql([empty_users.call, [ROM::Relation::Loaded.new(tasks.for_users, [])]])
  end
end
