require 'rom/commands/composite'
require 'rom/commands/graph'

module ROM
  module Commands
    # Abstract command class
    #
    # Provides a constructor accepting relation with options and basic behavior
    # for calling, currying and composing commands.
    #
    # Typically command subclasses should inherit from specialized
    # Create/Update/Delete, not this one.
    #
    # @abstract
    #
    # @private
    class Abstract
      include Options

      option :type, allow: [:create, :update, :delete]
      option :result, reader: true, allow: [:one, :many]
      option :target
      option :validator, reader: true
      option :input, reader: true
      option :curry_args, type: Array, reader: true, default: EMPTY_ARRAY

      attr_reader :relation

      # @api private
      def initialize(relation, options = {})
        @relation = relation
        super
      end

      # Execute the command
      #
      # @abstract
      #
      # @return [Array] an array with inserted tuples
      #
      # @api private
      def execute(*)
        raise(
          NotImplementedError,
          "#{self.class}##{__method__} must be implemented"
        )
      end

      # Call the command and return one or many tuples
      #
      # @api public
      def call(*args)
        tuples =
          if curry_args.first.is_a?(Proc)
            execute(*([curry_args.first.call(args.first)]+args[1..args.size]))
          else
            execute(*(curry_args + args))
          end

        if result == :one
          tuples.first
        else
          tuples
        end
      end
      alias_method :[], :call

      # Curry this command with provided args
      #
      # Curried command can be called without args
      #
      # @return [Command]
      #
      # @api public
      def curry(*args)
        self.class.new(relation, options.merge(curry_args: args))
      end
      alias_method :with, :curry

      # Compose a command with another one
      #
      # The other one will be called with the result from the first one
      #
      # @example
      #
      #   command = users.create.curry(name: 'Jane')
      #   command >>= tasks.create.curry(title: 'Task One')
      #
      #   command.call # creates user, passes it to tasks and creates task
      #
      # @return [Composite]
      #
      # @api public
      def >>(other)
        Composite.new(self, other)
      end

      # @api public
      def combine(*others)
        Graph.new(self, others)
      end

      # Return new update command with new relation
      #
      # @api private
      def new(*args, &block)
        self.class.build(relation.public_send(*args, &block), options)
      end

      # Target relation on which the command will operate
      #
      # By default this is set to the relation that's passed to the constructor.
      # Specialized commands like Delete may set the target to a different
      # relation.
      #
      # @return [Relation]
      #
      # @api public
      def target
        relation
      end

      # Assert that tuple count in the target relation corresponds to :result
      # setting
      #
      # @raise TupleCountMismatchError
      #
      # @api private
      def assert_tuple_count
        if result == :one && tuple_count > 1
          raise TupleCountMismatchError, "#{inspect} expects one tuple"
        end
      end

      # Return number of tuples in the target relation
      #
      # This should be overridden by gateways when `#count` is not available
      # in the relation objects
      #
      # @return [Fixnum]
      #
      # @api private
      def tuple_count
        target.count
      end

      # @api private
      def respond_to_missing?(name, _include_private = false)
        relation.respond_to?(name) || super
      end

      private

      # @api private
      def method_missing(name, *args, &block)
        if relation.respond_to?(name)
          new(name, *args, &block)
        else
          super
        end
      end
    end
  end
end
