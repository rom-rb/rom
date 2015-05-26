require 'rom/repository'
require 'rom/memory/storage'
require 'rom/memory/commands'

module ROM
  module Memory
    # In-memory repository interface
    #
    # @example
    #   repository = ROM::Memory::Gateway.new
    #   repository.dataset(:users)
    #   repository[:users].insert(name: 'Jane')
    #
    # @api public
    class Gateway < ROM::Gateway
      # @return [Object] default logger
      #
      # @api public
      attr_reader :logger

      # @api private
      def initialize
        @connection = Storage.new
      end

      # Set default logger for the repository
      #
      # @param [Object] logger object
      #
      # @api public
      def use_logger(logger)
        @logger = logger
      end

      # Register a dataset in the repository
      #
      # If dataset already exists it will be returned
      #
      # @return [Dataset]
      #
      # @api public
      def dataset(name)
        self[name] || connection.create_dataset(name)
      end

      # @see ROM::Gateway#dataset?
      def dataset?(name)
        connection.key?(name)
      end

      # Return dataset with the given name
      #
      # @param (see ROM::Gateway#[])
      # @return [Memory::Dataset]
      #
      # @api public
      def [](name)
        connection[name]
      end
    end
  end
end
