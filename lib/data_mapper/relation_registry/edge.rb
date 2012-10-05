module DataMapper
  class RelationRegistry

    class Edge

      attr_reader :a
      attr_reader :b
      attr_reader :op
      attr_reader :relations

      def initialize(a, b, op)
        @a  = a
        @b  = b
        @op = op

        @relations = Set[@a.relation, @b.relation]
        @hash      = @relations.hash ^ @op.hash
      end

      def source_side(relation)
        a?(relation) ? @a : @b
      end

      def target_side(relation)
        a?(relation) ? @b : @a
      end

      attr_reader :hash

      def eql?(other)
        return false unless instance_of?(other.class)
        @relations.eql?(other.relations) && @op.eql?(other.op)
      end

      def ==(other)
        return false unless self.class <=> other.class
        @relations == other.relations && @op == other.op
      end

      private

      def a?(relation)
        # TODO better error (message)
        raise ArgumentError unless @relations.include?(relation)
        relation == @a.relation
      end
    end # class Edge
  end # class RelationRegistry
end # module DataMapper
