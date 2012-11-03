require 'veritas'

module DataMapper
  class RelationRegistry
    class RelationNode < Graph::Node

      # Relation node wrapping veritas relation
      #
      class VeritasRelation < self
        include Enumerable

        attr_reader :relation
        attr_reader :aliases

        # TODO: add specs
        def each(&block)
          return to_enum unless block_given?
          relation.each(&block)
          self
        end

        # TODO: add specs
        def base?
          veritas_relation = relation.respond_to?(:relation) ? relation.send(:relation) : relation
          veritas_relation.instance_of?(Veritas::Relation::Base)
        end

        # TODO: add specs
        def rename(new_aliases)
          self.class.new(name, relation, aliases.merge(new_aliases))
        end

        # TODO: add specs
        def aliased
          self.class.new(name, relation.rename(aliases))
        end

        # TODO: add specs
        def join(other)
          self.class.new(name, relation.rename(aliases).join(other.aliased.relation))
        end

        # TODO: add specs
        def header
          relation.header
        end

        # TODO: add specs
        def restrict(*args, &block)
          self.class.new(name, relation.restrict(*args, &block), aliases)
        end

        # TODO: add specs
        def order(*attributes)
          sorted = relation.sort_by { |r| attributes.map { |attribute| r.send(attribute) } }
          self.class.new(name, sorted, aliases)
        end

        # TODO: add specs
        def sort_by(&block)
          self.class.new(name, relation.sort_by(&block), aliases)
        end

      end # class VeritasRelation

    end # class RelationNode
  end # class RelationRegistry
end # module DataMapper
