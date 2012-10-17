module DataMapper
  class RelationRegistry

    class RelationNode < Graph::Node
      include Enumerable

      attr_reader :relation

      attr_reader :aliases

      def initialize(name, relation, aliases = nil)
        super(name)
        @relation = relation
        @aliases  = aliases || AliasSet.new(name)
      end

      def each(&block)
        return to_enum unless block_given?
        relation.each(&block)
        self
      end

      def rename(new_aliases)
        self.class.new(name, relation.rename(new_aliases), aliases)
      end

      def join(other)
        relation.rename(aliases).join(other)
      end

      def header
        relation.header
      end

      def restrict(*args, &block)
        self.class.new(name, relation.restrict(*args, &block), aliases)
      end

      def sort_by(&block)
        self.class.new(name, relation.sort_by(&block), aliases)
      end

      def aliased_for(relationship)
        clone_for(relationship, aliases.merge(aliases_for_relationship(relationship)))
      end

      def aliases_for_relationship(relationship)
        aliases.exclude(relationship.target_key)
      end

      def clone_for(relationship, aliases = nil)
        self.class.new(:"#{name}_#{relationship.name}", relation, aliases)
      end

      def relation_for_join(relationship)
        relation.rename(aliases_for_relationship(relationship))
      end

    end # class RelationNode

  end # class RelationRegistry
end # module DataMapper
