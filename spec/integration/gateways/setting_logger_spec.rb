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
end
