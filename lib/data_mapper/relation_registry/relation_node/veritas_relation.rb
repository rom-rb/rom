module DataMapper
  class RelationRegistry
    class RelationNode < Graph::Node

      # Relation node wrapping veritas relation
      #
      class VeritasRelation < self
        include Enumerable

        attr_reader :relation

        attr_reader :aliases

        def each(&block)
          return to_enum unless block_given?
          relation.each(&block)
          self
        end

        def rename(new_aliases)
          self.class.new(name, relation, aliases.merge(new_aliases))
        end

        def aliased
          self.class.new(name, relation.rename(aliases), aliases)
        end

        def join(other)
          self.class.new(name, relation.rename(aliases).join(other.aliased.relation))
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

      end # class VeritasRelation

    end # class RelationNode
  end # class RelationRegistry
end # module DataMapper
