# frozen_string_literal: true

require "rom/relation/name"

RSpec.describe ROM::Relation::Name, "#aliased?" do
  let(:name) { ROM::Relation::Name[:users] }

  it "returns true when name is aliased" do
    expect(name.as(:people)).to be_aliased
  end

  it "returns true when name is not aliased" do
    expect(name).to_not be_aliased
  end
end
