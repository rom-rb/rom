# frozen_string_literal: true

require "rom/setup"

RSpec.describe ROM::Setup do
  it "is configurable via settings hash" do
    setup = ROM::Setup.new(:memory, "something", infer_schema: false)

    expect(setup.config.gateways.default.infer_schema).to be(false)

    setup = ROM::Setup.new(:memory, infer_schema: false)

    expect(setup.config.gateways.default.infer_schema).to be(false)

    setup = ROM::Setup.new(default: [:memory, infer_schema: false])

    expect(setup.config.gateways.default.infer_schema).to be(false)
  end

  describe "defining components when adapter was not registered" do
    it "raises error when trying to define a relation" do
      expect {
        Class.new(ROM::Relation[:not_here])
      }.to raise_error(ROM::AdapterNotPresentError, /not_here/)
    end

    it "raises error when trying to define a command" do
      expect {
        Class.new(ROM::Commands::Create[:not_here])
      }.to raise_error(ROM::AdapterNotPresentError, /not_here/)
    end
  end
end
