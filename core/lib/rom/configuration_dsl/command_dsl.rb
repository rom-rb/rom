# frozen_string_literal: true

require 'rom/configuration_dsl/command'

module ROM
  module ConfigurationDSL
    # Command `define` DSL used by Setup#commands
    #
    # @private
    class CommandDSL
      attr_reader :relation

      attr_reader :adapter

      attr_reader :command_classes

      # @api private
      def initialize(relation, adapter = nil, &)
        @relation = relation
        @adapter = adapter
        @command_classes = []
        instance_exec(&)
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
      def define(name, options = EMPTY_HASH, &)
        @command_classes << Command.build_class(
          name, relation, { adapter: adapter }.merge(options), &
        )
      end
    end
  end
end
