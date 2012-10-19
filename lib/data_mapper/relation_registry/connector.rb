module DataMapper
  class RelationRegistry

    class Connector
      attr_reader :name
      attr_reader :edge
      attr_reader :source_node
      attr_reader :target_node
      attr_reader :relationship
      attr_reader :operation

      def initialize(name, edge, relationship)
        @name         = name
        @edge         = edge
        @source_node  = edge.left
        @target_node  = edge.right
        @relationship = relationship
        @operation    = relationship.operation
      end

      def relation
        join = source_node.join(target_node.relation_for_join(relationship))
        join = join.instance_eval(&operation) if operation
        join
      end

      def aliased_for(relationship)
        self.class.new(
          name, edge.aliased_for(relationship, target_aliases), relationship
        )
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
        target_node.aliases_for(relationship)
      end

      def source_name
        source_node.name
      end

      def target_name
        target_node.name
      end

      def via?
        ! relationship.via.nil?
      end

      def via
        relationship.via
      end

      def collection_target?
        relationship.collection_target?
      end

    end # class Connector

  end # class RelationRegistry
end # module DataMapper
