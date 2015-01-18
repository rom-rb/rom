require 'spec_helper'
require 'rom/memory'

require 'logger'

describe 'Repositories / Setting logger' do
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

  it 'sets up a logger for a given repository' do
    setup = ROM.setup(:memory, 'memory://test')

    setup.default.use_logger(logger)

    rom = setup.finalize

    rom.repositories[:default].logger.info("test")

    expect(logger.messages).to eql(["test"])
  end
end
