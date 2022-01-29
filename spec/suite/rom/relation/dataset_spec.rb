# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#dataset" do
  it "returns dataset inferred from gateway" do
    module Test
      class Users < ROM::Relation[:memory]
      end
    end

    relation = Test::Users.new

    expect(relation.dataset).to be_empty
  end

  it "returns dataset that uses a custom schema" do
    module Test
      class Users < ROM::Relation[:memory]
        schema do
          attribute :id, Types::Integer
          attribute :name, Types::Integer
        end

        dataset do |schema|
          ds = ROM::Memory::Dataset.new([])

          ds.insert(id: 1, name: "Jane", email: "jane@doe.org")
          ds.insert(id: 2, name: "Joe", email: "joe@doe.org")

          ds.project(*schema.map(&:name))
        end
      end
    end

    relation = Test::Users.new

    expect(relation.dataset.to_a).to eql([{id: 1, name: "Jane"}, {id: 2, name: "Joe"}])
  end

  it "returns default dataset when there's no matching schema" do
    module Test
      class Users < ROM::Relation[:memory]
        schema(:listing) do
          attribute :id, Types::Integer
          attribute :name, Types::Integer
        end

        dataset do
          []
        end
      end
    end

    relation = Test::Users.new

    expect(relation.dataset).to be_empty
  end

  it "returns dataset that uses a custom schema with custom identifiers" do
    module Test
      class Users < ROM::Relation[:memory]
        schema(:listing) do
          attribute :id, Types::Integer
          attribute :name, Types::Integer
        end

        dataset(:listing) do |schema|
          ds = ROM::Memory::Dataset.new([])

          ds.insert(id: 1, name: "Jane", email: "jane@doe.org")
          ds.insert(id: 2, name: "Joe", email: "joe@doe.org")

          ds.project(*schema.map(&:name))
        end
      end
    end

    relation = Test::Users.new

    expect(relation.dataset.to_a).to eql([{id: 1, name: "Jane"}, {id: 2, name: "Joe"}])
  end
end
