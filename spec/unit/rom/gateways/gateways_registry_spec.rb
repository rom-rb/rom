# frozen_string_literal: true

require "spec_helper"

RSpec.describe ROM::Configuration do
  subject(:config) { ROM::Configuration.new(*params, &block) }

  let(:block) { proc {} }
  let(:gateways) { config.gateways }

  context "with an adapter identifier" do
    let(:params) { [:memory] }

    it "configures the gateways hash" do
      expect(gateways.keys).to eql([:default])
      expect(gateways[:default]).to be_kind_of(ROM::Memory::Gateway)
      expect(gateways[:default].config.name).to be(:default)
    end
  end

  context "with a block" do
    let(:params) { [:memory] }

    let(:block) do
      proc do |config|
        # TODO: ugh
        config.config.gateways.default.my_setting = "test"
      end
    end

    it "sets gateway's custom config" do
      expect(gateways[:default].config.name).to eql(:default)
      expect(gateways[:default].config.my_setting).to eql("test")
    end
  end

  context "with custom adapter settings" do
    let(:params) { [:memory, my_setting: "test"] }

    it "sets gateway's custom config" do
      expect(gateways[:default].config.name).to eql(:default)
      expect(gateways[:default].config.my_setting).to eql("test")
    end
  end

  context "with a hash" do
    let(:params) { [default: :memory] }

    it "configures the gateways hash" do
      expect(gateways.keys).to eql([:default])
      expect(gateways[:default]).to be_kind_of(ROM::Memory::Gateway)
    end
  end

  context "with multiple gateways" do
    let(:params) { [foo: :memory, default: :memory] }

    it "configures the gateways hash" do
      expect(gateways.keys).to eq(%i[foo default])
      expect(gateways[:default]).to be_kind_of(ROM::Memory::Gateway)
      expect(gateways[:foo]).to be_kind_of(ROM::Memory::Gateway)
      expect(gateways[:default]).not_to be(gateways[:foo])
    end
  end

  context "with settings" do
    before do
      module Test
        class Gateway < ROM::Gateway
          attr_reader :settings

          def initialize(settings = {})
            @settings = settings
          end
        end
      end

      ROM.register_adapter(:test, Test)
    end

    context "as a hash" do
      let(:params) { [foo: [:test, "foo"], bar: [:test, ["bar"]]] }

      it "configures the gateway instance" do
        expect(gateways.config.foo.adapter).to be(:test)
        expect(gateways.config.foo.args).to match_array(%w[foo])
        expect(gateways.config.bar.adapter).to be(:test)
        expect(gateways.config.bar.args).to match_array(%w[bar])
      end
    end

    context "as flat args" do
      let(:params) { [:test, "foo"] }

      it "configures the gateway instance" do
        expect(gateways.config.default.args).to match_array(["foo"])
      end
    end
  end

  context "with a Gateway instance" do
    before do
      module Test
        class Gateway < ROM::Gateway
          attr_reader :settings

          def initialize(settings = {})
            @settings = settings
          end
        end
      end

      ROM.register_adapter(:test, Test)
    end

    let(:gateway) { Test::Gateway.new }
    let(:params) { [gateway] }

    it "configures the gateways hash" do
      expect(gateways.keys).to eq([:default])
      expect(gateways[:default]).to be(gateway)
    end
  end
end
