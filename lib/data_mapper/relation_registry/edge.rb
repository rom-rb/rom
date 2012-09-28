module DataMapper
  class RelationRegistry

    class Edge

      attr_reader :a
      attr_reader :b
      attr_reader :relations

      def initialize(a, b)
        @a = a
        @b = b
        @relations = Set[@a.relation, @b.relation]
        @hash      = @relations.hash
      end

      attr_reader :hash

      def eql?(other)
        instance_of?(other.class) && @relations.eql?(other.relations)
      end

      def ==(other)
        self.class <=> other.class && @relations == other.relations
      end
    end # class Edge
  end # class RelationRegistry
end # module DataMapper
