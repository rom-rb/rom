# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#foreign_key" do
  subject(:relation) do
    Class.new(ROM::Relation) do
      schema(:users) do
        attribute :id, ROM::Types::Integer
        attribute :group_id, ROM::Types::Integer.meta(foreign_key: true, target: :groups)
      end
    end.new([])
  end

  it "returns FK name for the given relation name" do
    expect(relation.foreign_key(ROM::Relation::Name[:groups])).to be(:group_id)
  end

  it "returns FK name for the given relation name with a different dataset name" do
    expect(relation.foreign_key(ROM::Relation::Name[:user_groups, :groups])).to be(:group_id)
  end

  it "generates a virtual FK when real attribute is not found" do
    expect(relation.foreign_key(ROM::Relation::Name[:companies])).to be(:company_id)
  end
end
