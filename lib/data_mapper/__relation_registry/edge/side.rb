module DataMapper
  class RelationRegistry
    class Edge

      class Side
        attr_reader :node
        attr_reader :relation
        attr_reader :join_attributes

        def initialize(node, join_attributes)
          @node            = node
          @relation        = node.relation
          @join_attributes = Array(join_attributes)
        end
      end # class Side
    end # class Edge
  end # class RelationRegistry
end # module DataMapper
