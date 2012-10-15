module DataMapper
  class RelationRegistry

    class RelationConnector < Graph::Edge

      attr_reader :relationship

      def initialize(relationship, left, right)
        super(relationship.name, left, right)
        @relationship = relationship
      end

      def relation
        @left.join(@right, @relationship)
      end

      def join_via(relationship)
        aliases = target_aliases.exclude(relationship.target_key)
        self.class.new(relationship, left, @right.class.new(@right.name, @right.relation, aliases))
      end

      def source_model
        @relationship.source_model
      end

      def target_model
        @relationship.target_model
      end

      def via?
        ! @relationship.via.nil?
      end

      def via
        @relationship.via
      end

      def collection_target?
        @relationship.collection_target?
      end

      def source_aliases
        @left.aliases
      end

      def target_aliases
        @right.aliases.exclude(@relationship.target_key)
      end

    end # class RelationConnector

  end # class RelationRegistry
end # module DataMapper
