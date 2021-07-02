# frozen_string_literal: true

require "delegate"

require "rom/constants"

module ROM
  module Runtime
    class Configuration < SimpleDelegator
      include Dry::Equalizer(:configuration)

      alias_method :configuration, :__getobj__

      attr_reader :container

      # @api private
      def initialize(configuration: ROM::Configuration.new, container: EMPTY_HASH)
        super(configuration)
        @container = container
      end

      # @api private
      def relations
        container[:relations]
      end

      # @api private
      def mappers
        container[:mappers]
      end

      # @api private
      def commands
        container[:commands]
      end

      # @api private
      def cache
        configuration.cache
      end
    end
  end
end
