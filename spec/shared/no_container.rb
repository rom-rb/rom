# frozen_string_literal: true

RSpec.shared_context "no container" do
  require "rom/memory"

  let(:gateway) { ROM::Memory::Gateway.new }

  let(:users_dataset) { gateway.dataset(:users) }
  let(:tasks_dataset) { gateway.dataset(:tasks) }

  let(:users_relation) do
    Class.new(ROM::Memory::Relation).new(users_dataset)
  end

  let(:tasks_relation) do
    Class.new(ROM::Memory::Relation).new(tasks_dataset)
  end
end
