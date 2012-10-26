module DataMapper
  class RelationRegistry

    class RelationEdge < Graph::Edge
      attr_reader :relationship
      attr_reader :operation

      attr_reader :source_node
      attr_reader :target_node

      def initialize(relationship, left, right)
        super(relationship.name, left, right)
        @relationship = relationship
        @operation    = operation
        @source_node  = left
        @target_node  = right
      end

      def relation
        left, right = if source_node.base?
                 [ source_node, target_node ]
               else
                 [ target_node, source_node ]
               end

        join = left.join(right).relation
        join = join.instance_eval(&operation) if operation
        join
      end

      def source_model
        relationship.source_model
      end

      def target_model
        relationship.target_model
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

      def via?
        ! via.nil?
      end

      def via
        relationship.via
      end

      def collection_target?
        relationship.collection_target?
      end


    end # class RelationEdge

  end # class RelationRegistry
end # module DataMapper
