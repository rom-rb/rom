module DataMapper
  class RelationRegistry

    class Connector

      attr_reader :name
      attr_reader :edge
      attr_reader :node
      attr_reader :relation

      def initialize(name, edge, node)
        @name     = name
        @edge     = edge
        @node     = node
        @relation = @node.relation
      end
    end # class Connector
  end # class RelationRegistry
end # module DataMapper
