require "spec_helper"

describe Schema, "#[]" do
  subject(:schema) { Schema.new(users: relation) }

  fake(:relation)

  it "returns registered relation" do
    expect(schema[:users]).to be(relation)
  end

  it "raises error when relation is missing" do
    expect { schema[:not_here] }.to raise_error
  end
end
