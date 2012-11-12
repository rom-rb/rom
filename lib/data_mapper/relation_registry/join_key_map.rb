module DataMapper
  class RelationRegistry

    # Represent +left attribute name => right attribute name+ mappings
    # used to join two relation nodes
    #
    # @api private
    class JoinKeyMap

      include Enumerable

      include Equalizer.new(:left_keys, :right_keys)

      # The left node's attribute names to use for the join
      #
      # @return [Array]
      #
      # @api private
      attr_reader :left_keys

      # The right node's attribute names to use for the join
      #
      # @return [Array]
      #
      # @api private
      attr_reader :right_keys

      # Initialize a new instance
      #
      # @param [Array<Symbol>] left_keys
      #   the left node's attribute names to use for the join
      #
      # @param [Array<Symbol>] right_keys
      #   the right node's attribute names to use for the join
      #
      # @return [undefined]
      #
      # @api private
      def initialize(left_keys, right_keys)
        @left_keys  = left_keys
        @right_keys = right_keys

        @map = join_key_map
      end

      # Iterate over +left name => right name+ pairs
      #
      # @yield [left_name, right_name]
      #
      # @yieldparam [Symbol] left_name
      # @yieldparam [Symbol] right_name
      #
      # @return [self]
      #
      # @api private
      def each(&block)
        return to_enum unless block_given?
        @map.each(&block)
        self
      end

      private

      # @api private
      def join_key_map
        Hash[left_keys.zip(right_keys)]
      end
    end
  end
end
