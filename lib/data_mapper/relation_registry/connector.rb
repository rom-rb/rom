module DataMapper
  class RelationRegistry

    class Connector

      attr_reader :name
      attr_reader :edge
      attr_reader :relationship
      attr_reader :relation

      attr_reader :source_side
      attr_reader :target_side
      attr_reader :source_node
      attr_reader :target_node
      attr_reader :source_model
      attr_reader :target_model
      attr_reader :source_aliases
      attr_reader :target_aliases

      def initialize(source_node, target_node, edge, relationship)
        @source_node  = source_node
        @target_node  = target_node
        @edge         = edge
        @relationship = relationship
        @relation     = @target_node.relation
        @name         = @relationship.name
        @source_model = @relationship.source_model
        @target_model = @relationship.target_model

        @collection_target = @relationship.collection_target?

        source_relation = @source_node.relation

        @source_side = @edge.source_side(source_relation)
        @target_side = @edge.target_side(source_relation)

        @source_aliases = @target_node.aliases(@source_side)
        @target_aliases = @target_node.aliases(@target_side)
      end

      def collection_target?
        @collection_target
      end
    end # class Connector
  end # class RelationRegistry
end # module DataMapper
