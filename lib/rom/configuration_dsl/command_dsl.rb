# frozen_string_literal: true

require "rom/configuration_dsl/command"

module ROM
  module ConfigurationDSL
    # Command `define` DSL used by Setup#commands
    #
    # @private
    class CommandDSL
      attr_reader :configuration, :relation, :adapter

      # @api private
      def initialize(configuration, relation:, adapter: nil, &block)
        @configuration = configuration
        @relation = relation
        @adapter = adapter
        instance_exec(&block)
      end

      # Define a command class
      #
      # @param [Symbol] name of the command
      # @param [Hash] options
      # @option options [Symbol] :type The type of the command
      #
      # @return [Class] generated class
      #
      # @api public
      def define(name, options = EMPTY_HASH, &block)
        constant = Command.build_class(name, relation, {adapter: adapter}.merge(options), &block)
        configuration.components.add(:commands, constant: constant)
      end
    end
  end
end
