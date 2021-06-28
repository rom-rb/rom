# frozen_string_literal: true

require "spec_helper"

RSpec.describe ROM::Configuration do
  it "is configurable via settings hash" do
    configuration = ROM::Configuration.new(:memory, "something", infer_schema: false)

    expect(configuration.config.gateways.default.infer_schema).to be(false)

    configuration = ROM::Configuration.new(:memory, infer_schema: false)

    expect(configuration.config.gateways.default.infer_schema).to be(false)

    configuration = ROM::Configuration.new(default: [:memory, infer_schema: false])

    expect(configuration.config.gateways.default.infer_schema).to be(false)
  end

  describe "#[]" do
    it "returns a gateway if it is defined" do
      gateway = ROM::Gateway.setup(:memory)
      configuration = ROM::Configuration.new(gateway: gateway)

      expect(configuration[:gateway]).to be(gateway)
    end

    it "raises error if gateway is not defined" do
      configuration = ROM::Configuration.new

      expect { configuration[:not_here] }.to raise_error(KeyError, /not_here/)
    end
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
