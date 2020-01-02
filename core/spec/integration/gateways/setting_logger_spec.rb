require 'spec_helper'
require 'rom/memory'

require 'logger'

RSpec.describe 'Gateways / Setting logger' do
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

  it 'sets up a logger for a given gateway' do
    container = ROM.container(:memory) do |config|
      config.gateways[:default].use_logger(logger)
    end

    container.gateways[:default].logger.info('test')

    expect(logger.messages).to eql(['test'])
  end
end
