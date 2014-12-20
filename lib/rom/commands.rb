module ROM
  module Commands
    class AbstractCommand
      VALID_RESULTS = [:one, :many].freeze

      attr_reader :relation, :options, :result

      # @api private
      def initialize(relation, options)
        @relation = relation
        @options = options

        @result = options[:result] || :many

        unless VALID_RESULTS.include?(result)
          raise InvalidOptionError.new(:result, VALID_RESULTS)
        end
      end

      # Call the command and return one or many tuples
      #
      # @api public
      def call(*args)
        tuples = execute(*args)

        if result == :one
          tuples.first
        else
          tuples
        end
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
        if result == :one && target.size > 1
          raise TupleCountMismatchError, "#{inspect} expects one tuple"
        end
      end
    end
  end
end

require 'rom/commands/create'
require 'rom/commands/update'
require 'rom/commands/delete'
