# frozen_string_literal: true

require "rom/schema"

RSpec.describe ROM::Schema, "#exclude" do
  subject(:schema) do
    define_schema(:users, id: :Integer, name: :String, email: :String)
  end

  let(:excluded) do
    schema.exclude(:id, :name)
  end

  it "returns projected schema with renamed attributes using provided prefix" do
    expect(excluded.map(&:name)).to eql(%i[email])
  end
end
