module DataMapper
  class Relationship

    # Encapsulate information for both sides a join
    #
    # @see JoinDefinition::Side
    #
    # @api private
    class JoinDefinition

      # Represent one side of a join definition
      #
      # @!attribute [r] relation
      #   @return [Relation::Graph::Node] the relation for this side of the join
      #
      # @!attribute [r] keys
      #   @return [Array<Symbol>] the keys for this side of the join
      #
      # @api private
      class Side < Struct.new(:relation, :keys)

        private :relation=, :keys=

        # The relation name of this side of the join
        #
        # @return [#to_sym]
        #
        # @api private
        attr_reader :relation_name

        # Initialize a new instance
        #
        # @param [Object] relation
        #   an instance of the configured engine's relation class
        #
        # @param [Array<Symbol>] keys
        #   the attribute names to use for this side of the join
        #
        # @return [undefined]
        #
        # @api private
        def initialize(relation, keys)
          super(relation, Array(keys))
          @relation_name = relation.name
        end
      end # struct Side

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

        @map = Hash[@left.keys.zip(@right.keys)]
      end
    end # class JoinDefinition
  end # class Relationship
end # module DataMapper
