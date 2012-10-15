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
      end

      # TODO clean up this mess somehow
      def target_aliases
        @target_aliases ||= begin
          if @relationship.via

            # The target_aliases can't be initialized in the constructor
            # because of the need to access the finalized base relation
            # mappers below
            fields         = DataMapper[@target_model].attributes.fields
            aliased_fields = @target_side.node.aliased(fields)
            aliased_fields = @target_node.aliased(aliased_fields)

            Hash[fields.zip(aliased_fields)]
          else
            @target_node.aliases(@target_side)
          end
        end
      end

      def collection_target?
        @collection_target
      end
    end # class Connector
  end # class RelationRegistry
end # module DataMapper
