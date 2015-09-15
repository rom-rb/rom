require 'rom/support/options'
require 'rom/support/deprecations'

require 'rom/commands/composite'
require 'rom/commands/graph'
require 'rom/commands/lazy'

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
      extend Deprecations

      option :type, allow: [:create, :update, :delete]
      option :source, reader: true
      option :result, reader: true, allow: [:one, :many]
      option :validator, reader: true
      option :input, reader: true
      option :curry_args, type: Array, reader: true, default: EMPTY_ARRAY

      # @attr_reader [Relation] relation The command's relation
      attr_reader :relation

      deprecate :target, :relation,
        'Source relation is now available as `Command#source`'

      # @api private
      def initialize(relation, options = EMPTY_HASH)
        super
        @relation = relation
        @source = options[:source] || relation
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
        tuples = execute(*(curry_args + args))

        if one?
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
        if curry_args.empty? && args.first.is_a?(Graph::InputEvaluator)
          Lazy.new(self, *args)
        else
          self.class.build(relation, options.merge(curry_args: args))
        end
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

      # @api private
      def lazy?
        false
      end

      # @api private
      def graph?
        false
      end

      # @api private
      def one?
        result.equal?(:one)
      end

      # @api private
      def many?
        result.equal?(:many)
      end

      # Assert that tuple count in the relation corresponds to :result
      # setting
      #
      # @raise TupleCountMismatchError
      #
      # @api private
      def assert_tuple_count
        if one? && tuple_count > 1
          raise TupleCountMismatchError, "#{inspect} expects one tuple"
        end
      end

      # Return number of tuples in the relation relation
      #
      # This should be overridden by gateways when `#count` is not available
      # in the relation objects
      #
      # @return [Fixnum]
      #
      # @api private
      def tuple_count
        relation.count
      end

      # @api private
      def respond_to_missing?(name, _include_private = false)
        relation.respond_to?(name) || super
      end

      # @api private
      def new(new_relation)
        self.class.build(new_relation, options.merge(source: relation))
      end

      private

      # @api private
      def method_missing(name, *args, &block)
        if relation.respond_to?(name)
          response = relation.public_send(name, *args, &block)

          if response.instance_of?(relation.class)
            new(response)
          else
            response
          end
        else
          super
        end
      end
    end
  end
end
