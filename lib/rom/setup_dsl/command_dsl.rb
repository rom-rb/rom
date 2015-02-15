require 'rom/setup_dsl/command'

module ROM
  class Setup
    # Command `define` DSL used by Setup#commands
    #
    # @private
    class CommandDSL
      attr_reader :relation, :adapter

      # @api private
      def initialize(relation, adapter = nil, &block)
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
      def define(name, options = {}, &block)
        Command.build_class(
          name, relation, { adapter: adapter }.merge(options), &block
        )
      end
    end
  end
end
