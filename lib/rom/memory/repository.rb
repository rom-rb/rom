require 'rom/repository'
require 'rom/memory/storage'
require 'rom/memory/commands'

module ROM
  module Memory
    class Relation < ROM::Relation
      include Enumerable

      forward :join, :project, :restrict, :order

      def insert(*args)
        dataset.insert(*args)
        self
      end
      alias_method :<<, :insert

      def delete(*args)
        dataset.delete(*args)
        self
      end
    end

    class Repository < ROM::Repository
      attr_reader :logger

      def initialize
        @connection = Storage.new
      end

      def use_logger(logger)
        @logger = logger
      end

      def dataset(name)
        self[name] || connection.create_dataset(name)
      end

      def dataset?(name)
        connection.key?(name)
      end

      def [](name)
        connection[name]
      end

      def command_namespace
        Memory::Commands
      end
    end
  end
end
