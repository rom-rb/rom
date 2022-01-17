# frozen_string_literal: true

require "rom/core"
require "rom/memory"

RSpec.describe ROM::Plugins::Relation::Instrumentation do
  before do
    described_class.mixin Module.new
  end

  subject(:relation) do
    relation_class.new(dataset, notifications: notifications)
  end

  let(:dataset) do
    double(:dataset)
  end

  let(:relation_class) do
    Class.new(ROM::Memory::Relation) do
      config.component.id = :users

      schema do
        attribute :name, ROM::Types::String
      end

      use :instrumentation

      instrument def all
        self
      end
    end
  end

  let(:notifications) { spy(:notifications) }

  it "uses notifications API when materializing a relation" do
    relation.to_a

    expect(notifications).to have_received(:instrument).with(:memory, name: :users)
  end

  it "instruments custom methods" do
    relation.all

    expect(notifications).to have_received(:instrument).with(:memory, name: :users)
  end
end
