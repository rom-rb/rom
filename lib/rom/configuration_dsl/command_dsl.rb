# frozen_string_literal: true

require 'rom/configuration_dsl/command'

module ROM
  module ConfigurationDSL
    # Command `define` DSL used by Setup#commands
    #
    # @private
    class CommandDSL
      attr_reader :relation, :adapter, :command_classes

      # @api private
      def initialize(relation, adapter = nil, &block)
        @relation = relation
        @adapter = adapter
        @command_classes = []
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
        @command_classes << Command.build_class(
          name, relation, { adapter: adapter }.merge(options), &block
        )
      end
    end
  end
end
