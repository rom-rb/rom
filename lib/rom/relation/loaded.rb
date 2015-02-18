require 'rom/support/array_dataset'

module ROM
  class Relation
    # Wraps loaded data from a relation and gives access to its mappers
    #
    # @public
    class Loaded
      # Materialized relation
      #
      # @return [Relation]
      #
      # @api private
      attr_reader :relation

      # @return [ROM::MapperRegistry]
      #
      # @api private
      attr_reader :mappers

      # @api private
      def initialize(relation, mappers)
        @relation = relation.to_a
        @mappers = mappers
      end

      # Returns a single tuple from the relation if there is one.
      #
      # @raise [ROM::TupleCountMismatchError] if the relation contains more than
      #   one tuple
      #
      # @api public
      def one
        if relation.size > 1
          raise(
            TupleCountMismatchError,
            'The relation consists of more than one tuple'
          )
        else
          relation.first
        end
      end

      # Like [one], but additionally raises an error if the relation is empty.
      #
      # @raise [ROM::TupleCountMismatchError] if the relation does not contain
      #   exactly one tuple
      #
      # @api public
      def one!
        one || raise(
          TupleCountMismatchError,
          'The relation does not contain any tuples'
        )
      end

      # Map loaded relation using a specified mapper
      #
      # @example
      #
      #   loaded = rom.relation(:users) { |r| r.by_name('Jane') }
      #
      #   # mapping with a single mapper
      #   loaded.map_with(:entity_mapper)
      #
      #   # mapping with a multiple mappers
      #   loaded.map_with(:entity_mapper, :presenter_decorator)
      #
      # @return [Array] array of mapped tuples
      #
      # @api public
      def as(*names)
        result = relation
        names.each { |name| result = mappers[name].call(result) }
        result
      end
      alias_method :map_with, :as
    end
  end
end
