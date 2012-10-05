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

      def add_edge(new_edge, new_node, relationship = nil)
        edge = @edges << new_edge

        if relationship
          add_connector(relationship, edge, new_node)
        end

        self
      end

      def base_relation?
        false
      end

      attr_reader :hash

      def eql?(other)
        instance_of?(other.class) && @relation.eql?(other.relation)
      end

      def ==(other)
        return false unless self.class <=> other.class
        @relation == other.relation
      end

      private

      def add_connector(relationship, edge, node)
        connector = Connector.new(self, node, edge, relationship)
        @connectors[relationship.name] = connector
      end
    end # class Node
  end # class RelationRegistry
end # module DataMapper
