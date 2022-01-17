# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#name" do
  it "returns name inferred from demodulized class name" do
    module Test
      class Users < ROM::Relation[:memory]
      end
    end

    relation = Test::Users.new([])

    expect(relation.name.dataset).to be(:users)
    expect(relation.name.relation).to be(:users)
  end

  it "returns name inferred from schema" do
    module Test
      class Users < ROM::Relation[:memory]
        schema(:people)
      end
    end

    relation = Test::Users.new([])

    expect(relation.name.dataset).to be(:people)
    expect(relation.name.relation).to be(:users)
  end

  it "returns name inferred from schema with an alias" do
    module Test
      class Users < ROM::Relation[:memory]
        schema(:users, as: :people)
      end
    end

    relation = Test::Users.new([])

    expect(relation.name.dataset).to be(:users)
    expect(relation.name.relation).to be(:people)
  end

  it "returns name that's explicitly configured through custom id" do
    module Test
      class Users < ROM::Relation[:memory]
        config.component.id = :people
      end
    end

    relation = Test::Users.new([])

    expect(relation.name.dataset).to be(:users)
    expect(relation.name.relation).to be(:people)
  end

  it "returns name that's explicitly configured through custom dataset" do
    module Test
      class Users < ROM::Relation[:memory]
        config.component.dataset = :people
      end
    end

    relation = Test::Users.new([])

    expect(relation.name.dataset).to be(:people)
    expect(relation.name.relation).to be(:users)
  end

  it "returns name that's explicitly configured through custom id and dataset" do
    module Test
      class Users < ROM::Relation[:memory]
        config.component.id = :people
        config.component.dataset = :humans
      end
    end

    relation = Test::Users.new([])

    expect(relation.name.dataset).to be(:humans)
    expect(relation.name.relation).to be(:people)
  end
end
