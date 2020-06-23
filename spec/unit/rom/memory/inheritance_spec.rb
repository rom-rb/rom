# frozen_string_literal: true

require "rom/memory"

RSpec.describe ROM::Memory::Relation, ".inherited" do
  subject(:relation) do
    Class.new(ROM::Relation[:test]) do
      schema(:users) do
        attribute :name, ROM::Types::String
      end
    end.new([])
  end

  before do
    module Test
      module AnotherAdapter
        class Relation < ROM::Memory::Relation
          adapter :test
        end
      end
    end

    ROM.register_adapter(:test, Test::AnotherAdapter)
  end

  after do
    ROM.adapters.delete(:test)
  end

  it "extends subclass with core methods" do
    expect(relation.name.to_sym).to be(:users)
    expect(relation.schema.map(&:name)).to eql(%i[name])
  end
end
