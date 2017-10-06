module ROM
  class Relation
    # Interface for objects that can be materialized into a loaded relation
    #
    # @api public
    module Materializable
      include Enumerable

      # Coerce the relation to an array
      #
      # @return [Array]
      #
      # @api public
      def to_a
        call.to_a
      end
      alias_method :to_ary, :to_a

      # Yield relation tuples
      #
      # @yield [Hash,Object]
      #
      # @api public
      def each
        return to_enum unless block_given?
        to_a.each { |tuple| yield(tuple) }
      end

      # Delegate to loaded relation and return one object
      #
      # @return [Object]
      #
      # @see Loaded#one
      #
      # @api public
      def one
        call.one
      end

      # Delegate to loaded relation and return one object
      #
      # @return [Object]
      #
      # @see Loaded#one
      #
      # @api public
      def one!
        call.one!
      end

      # Return first tuple from a relation coerced to an array
      #
      # @return [Object]
      #
      # @api public
      def first
        to_a.first
      end
    end
  end
end
