# frozen_string_literal: true

require 'rom/gateway'
require 'rom/memory/storage'
require 'rom/memory/commands'

module ROM
  module Memory
    # In-memory gateway interface
    #
    # @example
    #   gateway = ROM::Memory::Gateway.new
    #   gateway.dataset(:users)
    #   gateway[:users].insert(name: 'Jane')
    #
    # @api public
    class Gateway < ROM::Gateway
      adapter :memory

      # @return [Object] default logger
      #
      # @api public
      attr_reader :logger

      # @api private
      def initialize
        @connection = Storage.new
      end

      # Set default logger for the gateway
      #
      # @param [Object] logger object
      #
      # @api public
      def use_logger(logger)
        @logger = logger
      end

      # Register a dataset in the gateway
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
