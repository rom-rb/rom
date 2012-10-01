module DataMapper
  class RelationRegistry

    # Abstract
    class Node

      attr_reader :name
      attr_reader :relation
      attr_reader :connectors
      attr_reader :edges

      def initialize(relation)
        @relation   = relation
        @connectors = {}
        @edges      = EdgeSet.new
        @hash       = @relation.hash
      end

      def [](name)
        @connectors[name]
      end

      def add_edge(new_edge, new_node, name = nil)
        edge = @edges << new_edge

        if name
          @connectors[name] = Connector.new(name, edge, new_node)
        end

        self
      end

      attr_reader :hash

      def eql?(other)
        instance_of?(other.class) && @relation.eql?(other.relation)
      end

      def ==(other)
        return false unless self.class <=> other.class
        @relation == other.relation
      end
    end # class Node
  end # class RelationRegistry
end # module DataMapper
