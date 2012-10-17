module DataMapper
  class RelationRegistry

    class RelationConnector < Graph::Edge

      attr_reader :relationship

      attr_reader :operation

      def initialize(relationship, left, right, operation = nil)
        super(relationship.name, left, right)
        @relationship = relationship
        @operation    = operation
      end

      def relation
        join = left.join(right.relation_for_join(relationship))
        join = join.instance_eval(&operation) if operation
        join
      end

      def aliased_for(relationship)
        aliases = right.aliases_for_relationship(relationship).merge(target_aliases)
        self.class.new(relationship, left, right.clone_for(relationship, aliases))
      end

      def source_model
        relationship.source_model
      end

      def target_model
        relationship.target_model
      end

      def source_aliases
        left.aliases
      end

      def target_aliases
        right.aliases_for_relationship(relationship)
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

    end # class RelationConnector

  end # class RelationRegistry
end # module DataMapper
