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
      option :args, type: Array, reader: true

      attr_reader :relation

      # @api private
      def initialize(relation, options = {})
        super
        @relation = relation
        @result ||= :many
        @validator ||= proc {}
        @input ||= Hash
        @args ||= []
      end

      # Call the command and return one or many tuples
      #
      # @api public
      def call(*args)
        tuples = execute(*(args + @args))

        if result == :one
          tuples.first
        else
          tuples
        end
      end

      # @api public
      def curry(*args)
        self.class.new(relation, options.merge(args: args))
      end

      # Compose a command with another one
      #
      # The other one will be called with the result from the first one
      #
      # @example
      #
      #   create_user_with_task = create_user >> create_task
      #   create_user_with_task.call({ name: 'Jane' }, { title: 'Task One' })
      #
      # @return [Proc]
      #
      # @api public
      def >>(other)
        Composite.new(self, other)
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
    end
  end
end
