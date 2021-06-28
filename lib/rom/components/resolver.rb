# frozen_string_literal: true

require "dry/effects"

module ROM
  module Components
    # Resolves registry items lazily at run-time
    #
    # @api public
    class Resolver < Proc
      include Dry::Effects::Handler.Reader(:configuration)

      attr_reader :configuration, :block

      # @api private
      def initialize(configuration, &block)
        @configuration = configuration
        @block = block
      end

      # @api private
      def call
        with_configuration(configuration, &block)
      end
    end
  end
end
