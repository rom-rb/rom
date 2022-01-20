# frozen_string_literal: true

require "rom/schema"

RSpec.describe ROM::Schema, "#canonical" do
  subject(:schema) {
    define_schema(:users, id: :Integer, name: :String)
  }

  it "returns self by default" do
    expect(schema.canonical).to be(schema)
  end

  it "returns canonical schema from a projected schema" do
    expect(schema.project(:id).canonical).to be(schema)
  end

  it "is canonical" do
    expect(schema).to be_canonical
  end

  it "is not canonical when projected" do
    expect(schema.project(:id)).to_not be_canonical
  end
end
