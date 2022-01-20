# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#schema" do
  it "returns schema inferred from demodulized class name" do
    module Test
      class Users < ROM::Relation[:memory]
      end
    end

    relation = Test::Users.new([])

    expect(relation.name.dataset).to be(:users)
    expect(relation.name.relation).to be(:users)

    expect(relation.schema.name.dataset).to be(:users)
    expect(relation.schema.name.relation).to be(:users)
  end

  it "returns schema that's explicitly defined" do
    module Test
      class Users < ROM::Relation[:memory]
        schema(:people)
      end
    end

    relation = Test::Users.new([])

    expect(relation.name.dataset).to be(:people)
    expect(relation.name.relation).to be(:users)

    expect(relation.schema.name.dataset).to be(:people)
    expect(relation.schema.name.relation).to be(:users)
  end
end
