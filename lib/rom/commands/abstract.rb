require 'rom/commands/composite'

module ROM
  module Commands
    class Abstract
      include Options

      option :type, allow: [:create, :update, :delete]
      option :result, reader: true, allow: [:one, :many]
      option :target
      option :validator, reader: true
      option :input, reader: true
      option :curry_args, type: Array, reader: true, default: []

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
        tuples = execute(*(args + curry_args))

        if result == :one
          tuples.first
        else
          tuples
        end
      end

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
      # @raises TupleCountMismatchError
      #
      # @api private
      def assert_tuple_count
        if result == :one && tuple_count > 1
          raise TupleCountMismatchError, "#{inspect} expects one tuple"
        end
      end

      # Return number of tuples in the target relation
      #
      # This should be overridden by repositories when `#count` is not available
      # in the relation objects
      #
      # @return [Fixnum]
      #
      # @api private
      def tuple_count
        target.count
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
