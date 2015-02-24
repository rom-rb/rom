module ROM
  class Relation
    # Materializes a relation and exposes interface to access the data
    #
    # @public
    class Loaded
      include Enumerable

      # Source relation
      #
      # @return [Relation]
      #
      # @api private
      attr_reader :source

      # Materialized relation
      #
      # @return [Object]
      #
      # @api private
      attr_reader :collection

      # @api private
      def initialize(source, collection = source.to_a)
        @source = source
        @collection = collection
      end

      # Yield relation tuples
      #
      # @yield [Hash]
      #
      # @api public
      def each(&block)
        return to_enum unless block
        collection.each(&block)
      end

      # @api public
      def new(collection)
        self.class.new(source, collection)
      end

      # Returns a single tuple from the relation if there is one.
      #
      # @raise [ROM::TupleCountMismatchError] if the relation contains more than
      #   one tuple
      #
      # @api public
      def one
        if collection.count > 1
          raise(
            TupleCountMismatchError,
            'The relation consists of more than one tuple'
          )
        else
          collection.first
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
