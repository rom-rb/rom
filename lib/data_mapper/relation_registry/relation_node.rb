module DataMapper
  class RelationRegistry

    class RelationNode < Graph::Node
      attr_reader :relation

      attr_reader :aliases

      def initialize(name, relation, aliases = nil)
        super(name)
        @relation = relation
        @aliases  = aliases || AliasSet.new(name)
      end

      def join_via(relationship)
        self.class.new(name, relation, aliases.exclude(relationship.target_key))
      end

      def join(other, relationship)
        relation.rename(aliases).join(other.relation_for_join(relationship)).optimize
      end

      def key_aliases(relationship)
        { relationship.source_key => relationship.target_key }
      end

      def relation_for_join(relationship)
        relation.rename(aliases_for_join(relationship)).optimize
      end

      def aliases_for_join(relationship)
        aliases.exclude(relationship.target_key)
      end

    end # class RelationNode

  end # class RelationRegistry
end # module DataMapper
