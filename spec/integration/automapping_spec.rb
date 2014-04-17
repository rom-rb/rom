require "spec_helper"

describe "Automapping relations" do
  let(:expected_relation) do
    mapper = ROM::Mapper.build([[:id, key: true, type: Integer], [:name, key: false, type: String]])
    relation = env.schema[:users]
    ROM::Relation.new(relation, mapper)
  end

  let(:env) { ROM::Environment.setup(test: "memory://test") }

  it "allows to automatically generate mappings for all relations" do
    env.schema(automap: true) do
      base_relation :users do
        repository :test

        attribute :id, Integer
        attribute :name, String

        key :id
      end
    end

    env.finalize

    expect(env[:users]).to eql(expected_relation)
  end

  it "allows to automatically generate mappings for a specific relation" do
    env.schema do
      base_relation :users, automap: true do
        repository :test

        attribute :id, Integer
        attribute :name, String

        key :id
      end
    end

    env.finalize

    expect(env[:users]).to eql(expected_relation)
  end
end
