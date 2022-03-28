# frozen_string_literal: true

require "rom/memory"

RSpec.describe ROM::Gateway, "#command" do
  subject(:gateway) do
    Class.new(ROM::Gateway) do
      adapter :test
    end.new
  end

  let(:command_type) do
    ROM::Memory::Commands::Create
  end

  let(:relation) do
    ROM::Relation.new
  end

  it "returns a command instance" do
    command = gateway.command(command_type, relation: relation)

    expect(command).to be_instance_of(command_type)
    expect(command.relation).to be(relation)
  end
end
