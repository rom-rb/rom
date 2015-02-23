module ROM
  class Relation
    # Materializes a relation and exposes interface to access the data
    #
    # @public
    class Loaded
      include Enumerable

      # Materialized relation
      #
      # @return [Relation]
      #
      # @api private
      attr_reader :relation

      # @api private
      def initialize(relation)
        @relation = relation.to_a
      end

      # Yield relation tuples
      #
      # @yield [Hash]
      #
      # @api public
      def each(&block)
        return to_enum unless block
        relation.each(&block)
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
    end
  end
end
