require "spec_helper"

describe "Automapping relations" do
  let(:expected_relation) do
    mapper = ROM::Mapper.build { map :id, :name }
    relation = env.schema[:users]

    ROM::Relation.new(relation, mapper)
  end

  it "allows to automatically generate mappings for all relations" do
    pending "not implemented yet"

    env = ROM::Environment.setup(test: "memory://test") do
      schema(automap: true) do
        base_relation :users do
          repository :test

          attribute :id, Integer
          attribute :name, String

          key :id
        end
      end
    end

    expect(env[:users]).to eql(expected_relation)
  end

  it "allows to automatically generate mappings for a specific relation" do
    pending "not implemented yet"

    env = ROM::Environment.setup(test: "memory://test") do
      schema do
        base_relation :users, automap: true do
          repository :test

          attribute :id, Integer
          attribute :name, String

          key :id
        end
      end
    end

    expect(env[:users]).to eql(expected_relation)
  end
end
