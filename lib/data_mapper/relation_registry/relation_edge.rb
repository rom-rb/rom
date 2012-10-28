module DataMapper
  class RelationRegistry

    class RelationEdge < Graph::Edge
      attr_reader :source_node
      attr_reader :target_node

      def initialize(name, left, right)
        super
        @source_node  = left
        @target_node  = right
      end

      def relation
        left, right = if source_node.base?
                        [ source_node, target_node ]
                      else
                        [ target_node, source_node ]
                      end

        left.join(right).relation
      end

      def source_aliases
        source_node.aliases
      end

      def target_aliases
        target_node.aliases
      end

      def source_name
        source_node.name
      end

      def target_name
        target_node.name
      end

    end # class RelationEdge

  end # class RelationRegistry
end # module DataMapper
