# frozen_string_literal: true

require 'rom/lint/linter'

module ROM
  module Lint
    # Ensures that a [ROM::Gateway] extension provides datasets through the
    # expected methods
    #
    # @api public
    class Gateway < ROM::Lint::Linter
      # The gateway identifier e.g. +:memory+
      #
      # @api public
      attr_reader :identifier

      # The gateway class
      #
      # @api public
      attr_reader :gateway

      # The optional URI
      #
      # @api public
      attr_reader :uri

      # Gateway instance used in lint tests
      #
      # @api private
      attr_reader :gateway_instance

      # Create a gateway linter
      #
      # @param [Symbol] identifier
      # @param [Class] gateway
      # @param [String] uri optional
      def initialize(identifier, gateway, uri = nil)
        @identifier = identifier
        @gateway = gateway
        @uri = uri
        @gateway_instance = setup_gateway_instance
      end

      # Lint: Ensure that +gateway+ setups up its instance
      #
      # @api public
      def lint_gateway_setup
        return if gateway_instance.instance_of? gateway

        complain <<-STRING
          #{gateway}.setup must return a gateway instance but
          returned #{gateway_instance.inspect}
        STRING
      end

      # Lint: Ensure that +gateway_instance+ responds to +[]+
      #
      # @api public
      def lint_dataset_reader
        return if gateway_instance.respond_to? :[]

        complain "#{gateway_instance} must respond to []"
      end

      # Lint: Ensure that +gateway_instance+ responds to +dataset?+
      #
      # @api public
      def lint_dataset_predicate
        return if gateway_instance.respond_to? :dataset?

        complain "#{gateway_instance} must respond to dataset?"
      end

      # Lint: Ensure +gateway_instance+ supports +transaction+ interface
      #
      # @api public
      def lint_transaction_support
        result = gateway_instance.transaction { 1 }

        complain "#{gateway_instance} must return the result of a transaction block" if result != 1

        gateway_instance.transaction do |t|
          t.rollback!

          complain "#{gateway_instance} must interrupt a transaction on rollback"
        end
      end

      # Lint: Ensure +gateway_instance+ returns adapter name
      def lint_adapter_reader
        if gateway_instance.adapter != identifier
          complain "#{gateway_instance} must have the adapter identifier set to #{identifier.inspect}"
        end
      rescue MissingAdapterIdentifierError
        complain "#{gateway_instance} is missing the adapter identifier"
      end

      private

      # Setup gateway instance
      #
      # @api private
      def setup_gateway_instance
        if uri
          ROM::Gateway.setup(identifier, uri)
        else
          ROM::Gateway.setup(identifier)
        end
      end

      # Run Gateway#disconnect
      #
      # @api private
      def after_lint
        super
        gateway_instance.disconnect
      end
    end
  end
end
