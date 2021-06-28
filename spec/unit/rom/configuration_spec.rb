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

  describe "#method_missing" do
    it "returns a gateway if it is defined" do
      repo = ROM::Gateway.setup(:memory)
      configuration = ROM::Configuration.new(repo: repo)

      expect(configuration.repo).to be(repo)
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
      repo = ROM::Gateway.setup(:memory)
      configuration = ROM::Configuration.new(repo: repo)

      expect(configuration[:repo]).to be(repo)
    end

    it "raises error if repo is not defined" do
      configuration = ROM::Configuration.new({})

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
