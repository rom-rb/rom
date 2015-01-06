require 'rom/adapter'

require 'rom/adapter/memory/storage'
require 'rom/adapter/memory/dataset'
require 'rom/adapter/memory/commands'

module ROM
  class Adapter
    class Memory < Adapter
      attr_accessor :logger

      def self.schemes
        [:memory]
      end

      def initialize(*args)
        super
        @connection = Storage.new
      end

      def dataset(name)
        connection.create_dataset(name)
      end

      def dataset?(name)
        connection.key?(name)
      end

      def [](name)
        connection[name]
      end
    end
  end
end
