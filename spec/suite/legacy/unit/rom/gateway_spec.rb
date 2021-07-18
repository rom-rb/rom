# frozen_string_literal: true

require "spec_helper"

RSpec.describe ROM::Gateway do
  subject(:gateway) { Class.new(ROM::Gateway).new }

  describe ".setup" do
    it "sets up a gateway based on a type" do
      gateway_class = Class.new(ROM::Gateway) do
        attr_reader :args

        def initialize(*args)
          @args = args
        end
      end

      allow(ROM::Gateway).to receive(:class_from_symbol)
        .with(:wormhole).and_return(gateway_class)

      args = %w[hello world]
      gateway = ROM::Gateway.setup(:wormhole, *args)

      expect(gateway).to be_instance_of(gateway_class)
      expect(gateway.args).to eq(args)
    end

    it "raises an exception if the type is not supported" do
      expect {
        ROM::Gateway.setup(:bogus, "memory://test")
      }.to raise_error(ROM::AdapterLoadError, /bogus/)
    end

    it "accepts a gateway instance" do
      gateway = ROM::Gateway.new
      expect(ROM::Gateway.setup(gateway)).to be(gateway)
    end

    it "raises an exception if instance and arguments are passed" do
      gateway = ROM::Gateway.new

      expect { ROM::Gateway.setup(gateway, "foo://bar") }.to raise_error(
        ArgumentError,
        "Can't accept arguments when passing an instance"
      )
    end

    it "raises an exception if a URI string is passed" do
      expect { ROM::Gateway.setup("memory://test") }.to raise_error(
        ArgumentError,
        /URIs without an explicit scheme are not supported anymore/
      )
    end
  end

  describe ".class_from_symbol" do
    context "when adapter is already present" do
      before do
        module Test
          module Adapter
            class Gateway
            end
          end
        end

        ROM.register_adapter(:test_adapter, Test::Adapter)
      end

      it "does not try to require an adapter if it is already present" do
        klass = ROM::Gateway.class_from_symbol(:test_adapter)

        expect(klass).to be(Test::Adapter::Gateway)
      end
    end

    it "instantiates a gateway based on type" do
      klass = ROM::Gateway.class_from_symbol(:memory)
      expect(klass).to be(ROM::Memory::Gateway)
    end

    it "raises an exception if the type is not supported" do
      expect { ROM::Gateway.class_from_symbol(:bogus) }
        .to raise_error(ROM::AdapterLoadError, /bogus/)
    end
  end

  describe "#disconnect" do
    it "does nothing" do
      expect(gateway.disconnect).to be(nil)
    end
  end

  describe "#logger" do
    it "does nothing" do
      expect(gateway.logger).to be(nil)
    end
  end

  describe "#use_logger" do
    it "does nothing" do
      expect(gateway.use_logger).to be(nil)
    end

    it "accepts parameters" do
      params = [5, "mutations", "are", "nice"]

      expect { gateway.use_logger(params) }.to_not raise_error
    end
  end

  describe ".adapter" do
    let(:gateway_class) { Class.new(ROM::Gateway) }

    it "gets/sets the adapter" do
      expect { gateway_class.adapter :custom }
        .to change { gateway_class.adapter }
        .from(nil)
        .to(:custom)
    end
  end

  describe "#adapter" do
    before { Test::CustomGateway = Class.new(ROM::Gateway) }

    let(:gateway) { Test::CustomGateway.new }

    it "returns class adapter" do
      Test::CustomGateway.adapter :custom
      expect(gateway.adapter).to eql :custom
    end

    it "requires the adapter to be defined" do
      expect { gateway.adapter }.to raise_error(
        ROM::MissingAdapterIdentifierError, /Test::CustomGateway/
      )
    end
  end # describe #adapter
end
