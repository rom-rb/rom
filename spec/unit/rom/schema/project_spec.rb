# frozen_string_literal: true

require "rom/schema"

RSpec.describe ROM::Schema, "#project" do
  subject(:schema) do
    define_schema(:users, id: :Integer, name: :String, age: :Integer)
  end

  it "projects provided attribute names" do
    expect(schema.project(:name, :age).map(&:name)).to eql(%i[name age])
  end

  it "projects provided attributes" do
    expect(schema.project(schema[:name], schema[:age]).map(&:name)).to eql(%i[name age])
  end
end
