require 'rom/repository'
require 'rom/memory/storage'
require 'rom/memory/commands'

module ROM
  module Memory
    # In-memory repository interface
    #
    # @example
    #   repository = ROM::Memory::Repository.new
    #   repository.dataset(:users)
    #   repository[:users].insert(name: 'Jane')
    #
    # @public
    class Repository < ROM::Repository
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

      # @see ROM::Repository#dataset?
      def dataset?(name)
        connection.key?(name)
      end

      # @see ROM::Repository#[]
      def [](name)
        connection[name]
      end

      def command_namespace
        Memory::Commands
      end
    end
  end
end
