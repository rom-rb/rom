# frozen_string_literal: true

require "dry/core/equalizer"

module ROM
  class Relation
    # Materializes a relation and exposes interface to access the data.
    #
    # This relation type is returned when a lazy relation is called
    #
    # @api public
    class Loaded
      include Enumerable
      include Dry::Equalizer(:source, :collection)

      # Coerce loaded relation to an array
      #
      # @return [Array]
      #
      # @api public
      alias_method :to_ary, :to_a

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
      def each
        return to_enum unless block_given?

        collection.each { |tuple| yield(tuple) }
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
            "The relation consists of more than one tuple"
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
          "The relation does not contain any tuples"
        )
      end

      # Return a list of values under provided key
      #
      # @example
      #   all_users = rom.relations[:users].call
      #   all_users.pluck(:name)
      #   # ["Jane", "Joe"]
      #
      # @param [Symbol] key The key name
      #
      # @return [Array]
      #
      # @raise KeyError when provided key doesn't exist in any of the tuples
      #
      # @api public
      def pluck(key)
        map { |tuple| tuple.fetch(key) }
      end

      # Pluck primary key values
      #
      # This method *may not work* with adapters that don't provide relations
      # that have primary key configured
      #
      # @example
      #   users = rom.relations[:users].call
      #   users.primary_keys
      #   # [1, 2, 3]
      #
      # @return [Array]
      #
      # @api public
      def primary_keys
        pluck(source.primary_key)
      end

      # Return if loaded relation is empty
      #
      # @return [TrueClass,FalseClass]
      #
      # @api public
      def empty?
        collection.empty?
      end

      # Return a loaded relation with a new collection
      #
      # @api public
      def new(collection)
        self.class.new(source, collection)
      end
    end
  end
end
