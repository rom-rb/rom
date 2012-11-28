module DataMapper
  class Relationship

    # Encapsulate information for both sides a join
    #
    # @see JoinDefinition::Side
    #
    # @api private
    class JoinDefinition

      class Side

        include Equalizer.new(:relation_name, :keys)

        # The relation name of this side of the join
        #
        # @return [Array<Symbol>]
        #
        # @api private
        attr_reader :relation_name

        # The attribute names to use for this side of the join
        #
        # @return [Array<Symbol>]
        #
        # @api private
        attr_reader :keys

        private

        # Initialize a new instance
        #
        # @param [#to_sym] relation_name
        #   the relation name for this side of the join
        #
        # @param [Array<Symbol>] attribute_names
        #   the attribute names to use for this side of the join
        #
        # @return [undefined]
        #
        # @api private
        def initialize(relation_name, keys)
          @relation_name, @keys = relation_name, Array(keys)
        end
      end # class Side

      include Enumerable

      include Equalizer.new(:to_hash)

      # The left side of the join
      #
      # @return [Side]
      #
      # @api private
      attr_reader :left

      # The right side of the join
      #
      # @return [Side]
      #
      # @api private
      attr_reader :right

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

      def to_hash
        @map.dup
      end

      private

      # Initialize a new instance
      #
      # @param [Side] left
      #   the left side of the join
      #
      # @param [Side] right
      #   the right side of the join
      #
      # @return [undefined]
      #
      # @api private
      def initialize(left, right)
        @left, @right = left, right

        left_keys  = aliased_keys(left.keys, left.relation_name)
        right_keys = aliased_keys(right.keys, right.relation_name)

        @map = Hash[left_keys.zip(right_keys)]
      end

      def aliased_keys(keys, relation_name)
        keys.map { |key| Mapper::Attribute.aliased_field(key, relation_name) }
      end
    end # class JoinDefinition
  end # class Relationship
end # module DataMapper
