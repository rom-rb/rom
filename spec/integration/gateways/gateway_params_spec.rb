# frozen_string_literal: true

RSpec.describe ROM, ".container" do
  let(:conf) do
    ROM::Configuration.new(:test_adapter, :param, option: :option)
  end

  let(:container) do
    ROM.container(conf)
  end

  let(:gateway) do
    container.gateways[:default]
  end

  shared_context "gateway" do
    it "builds a gateway with the provided configuration" do
      expect(gateway.param).to eql(:param)
      expect(gateway.option).to eql(:option)
    end
  end

  before do
    ROM.register_adapter(:test_adapter, Test)
  end

  context "kwargs" do
    before do
      module Test
        class Gateway < ROM::Gateway
          extend ROM::Initializer

          param :param
          option :option
        end
      end
    end

    include_context "gateway"
  end

  context "options" do
    before do
      module Test
        class Gateway < ROM::Gateway
          attr_reader :param, :option

          def initialize(param, options)
            @param = param
            @option = options[:option]
          end
        end
      end
    end

    include_context "gateway"
  end
end
