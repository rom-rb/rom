# frozen_string_literal: true

require "rom/schema"

RSpec.describe ROM::Schema, "#uniq" do
  subject(:schema) { left.merge(right) }

  let(:left) do
    define_schema(:users, id: :Integer, name: :String)
  end

  let(:right) do
    define_schema(:tasks, id: :Integer, user_id: :Integer)
  end

  it "returns a new schema with unique attributes from two schemas" do
    expect(schema.uniq.map(&:name)).to eql(%i[id name user_id])
  end

  it "accepts a block" do
    expect(schema.uniq(&:primitive).map(&:name)).to eql(%i[id name])
  end
end
