# frozen_string_literal: true

require "spec_helper"
require "rom/memory"

require "logger"

RSpec.describe "Gateways / Setting logger" do
  let(:logger_class) do
    Class.new do
      attr_reader :messages

      def initialize
        @messages = []
      end

      def info(msg)
        @messages << msg
      end
    end
  end

  let(:logger) do
    logger_class.new
  end

  it "works" do
    gateway = ROM::Memory::Gateway.new
    gateway.use_logger(logger)

    gateway.logger.info("test")

    expect(logger.messages).to include("test")
  end
end
