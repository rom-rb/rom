require 'veritas'

module DataMapper
  class RelationRegistry
    class RelationNode < Graph::Node

      # Relation node wrapping veritas relation
      #
      class VeritasRelation < self
        include Enumerable

        # Iterates over relation tuples
        #
        # @return [self, Enumerator]
        #
        # @yield [Veritas::Tuple]
        #
        # @api public
        def each(&block)
          return to_enum unless block_given?
          relation.each(&block)
          self
        end

        # Returns if the relation is a base relation
        #
        # @return [Boolean]
        #
        # @api private
        def base?
          veritas_relation = relation.respond_to?(:relation) ? relation.send(:relation) : relation
          veritas_relation.instance_of?(Veritas::Relation::Base)
        end

        # Renames the relation with given aliases
        #
        # @param [AliasSet]
        #
        # @return [VeritasRelation]
        #
        # @api public
        def rename(new_aliases)
          self.class.new(name, relation, aliases.merge(new_aliases))
        end

        # Renames relation using this relation node aliases
        #
        # @return [VeritasRelation]
        #
        # @api private
        def aliased
          self.class.new(name, relation.rename(aliases))
        end

        # Joins two nodes
        #
        # @param [VeritasRelation]
        #
        # @return [VeritasRelation]
        #
        # @api public
        def join(other)
          self.class.new(name, relation.rename(aliases).join(other.aliased.relation))
        end

        # Returns header for the veritas relation
        #
        # @return [Veritas::Header]
        #
        # @api private
        def header
          relation.header
        end

        # Restricts the relation and returns new node
        #
        # @param [*args] anything that Veritas::Relation::Base#restrict accepts
        #
        # @param [Proc]
        #
        # @return [VeritasRelation]
        #
        # @api public
        def restrict(*args, &block)
          self.class.new(name, relation.restrict(*args, &block), aliases)
        end

        # Sorts the relation and returns new node
        #
        # @param [*attributes]
        #
        # @return [VeritasRelation]
        #
        # @api public
        def order(*attributes)
          sorted = relation.sort_by { |r| attributes.map { |attribute| r.send(attribute) } }
          self.class.new(name, sorted, aliases)
        end

        # Sorts relation and returns new node
        #
        # @param [Proc]
        #
        # @return [VeritasRelation]
        #
        # @api public
        def sort_by(&block)
          self.class.new(name, relation.sort_by(&block), aliases)
        end

      end # class VeritasRelation

    end # class RelationNode
  end # class RelationRegistry
end # module DataMapper
