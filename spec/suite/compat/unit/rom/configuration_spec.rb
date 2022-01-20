# frozen_string_literal: true

require "rom/compat"

RSpec.describe ROM::Configuration do
  describe "#method_missing" do
    it "returns a gateway if it is defined" do
      gateway = ROM::Gateway.setup(:memory)
      configuration = ROM::Configuration.new(gw: gateway)

      expect(configuration.gw).to be(gateway)
    end

    it "exposes gateways in the block" do
      ROM::Configuration.new(:memory) do |config|
        expect(config.default).to be_a(ROM::Memory::Gateway)
      end
    end

    it "raises error if gateway is not defined" do
      configuration = ROM::Configuration.new

      expect { configuration.not_here }.to raise_error(NoMethodError, /not_here/)
    end
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

  describe "setting inflector" do
    example "is supported" do
      inflector = double(:inflector)

      configuration = ROM::Configuration.new(:memory, "something") do |conf|
        conf.inflector = inflector
      end

      expect(configuration.inflector).to be(inflector)
    end
  end
end
