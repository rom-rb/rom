# frozen_string_literal: true

require "spec_helper"

RSpec.describe ROM::Environment do
  let(:environment) { ROM::Environment.new(*params) }
  let(:params) { [] }
  let(:gateways) { environment.gateways }
  let(:gateways_map) { environment.gateways_map }

  context "with an adapter identifier" do
    let(:params) { [:memory] }

    it "configures the gateways hash" do
      expect(gateways).to be_kind_of(Hash)
      expect(gateways.keys).to eql([:default])
      expect(gateways[:default]).to be_kind_of(ROM::Memory::Gateway)
    end

    it "configures the gateways_map hash" do
      expect(gateways_map).to be_kind_of(Hash)
      expect(gateways_map.values).to eql([:default])
      expect(gateways_map.keys.first).to be_kind_of(ROM::Memory::Gateway)
      expect(gateways_map.keys.first).to be(gateways[:default])
    end
  end

  context "with a hash" do
    let(:params) { [default: :memory] }

    it "configures the gateways hash" do
      expect(gateways).to be_kind_of(Hash)
      expect(gateways.keys).to eql([:default])
      expect(gateways[:default]).to be_kind_of(ROM::Memory::Gateway)
    end

    it "configures the gateways_map hash" do
      expect(gateways_map).to be_kind_of(Hash)
      expect(gateways_map.values).to eql([:default])
      expect(gateways_map.keys.first).to be_kind_of(ROM::Memory::Gateway)
      expect(gateways_map.keys.first).to be(gateways[:default])
    end
  end

  context "with multiple gateways" do
    let(:params) { [foo: :memory, default: :memory] }

    it "configures the gateways hash" do
      expect(gateways).to be_kind_of(Hash)
      expect(gateways.keys).to eq(%i[foo default])
      expect(gateways[:default]).to be_kind_of(ROM::Memory::Gateway)
      expect(gateways[:foo]).to be_kind_of(ROM::Memory::Gateway)
      expect(gateways[:default]).not_to be(gateways[:foo])
    end

    it "configures the gateways_map hash" do
      expect(gateways_map).to be_kind_of(Hash)
      expect(gateways_map.values).to eq(%i[foo default])
      expect(gateways_map.keys.map(&:class)).to eq([ROM::Memory::Gateway, ROM::Memory::Gateway])
      expect(gateways_map.keys).to match_array(gateways.values)
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
        expect(gateways.values.map(&:settings)).to match_array(%w[foo bar])
      end
    end

    context "as flat args" do
      let(:params) { [:test, "foo"] }

      it "configures the gateway instance" do
        expect(gateways.values.map(&:settings)).to match_array(["foo"])
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
      expect(gateways).to be_kind_of(Hash)
      expect(gateways.keys).to eq([:default])
      expect(gateways[:default]).to be(gateway)
    end

    it "configures the gateways_map hash" do
      expect(gateways_map).to be_kind_of(Hash)
      expect(gateways_map[gateway]).to be(:default)
    end
  end
end
