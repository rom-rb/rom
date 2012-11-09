module DataMapper
  class RelationRegistry
    class Builder

      # Set of relation names for a given relationship
      #
      class NodeNameSet
        include Enumerable

        # A hash returned from {MapperRegistry#relation_map}
        #
        # @see MapperRegistry#relation_map
        #
        # @return [Hash{Class => Symbol}]
        #
        # @api private
        attr_reader :relations

        # Initializes a node name set
        #
        # @param [Relationship] relationship
        #   the relationship used to define the set
        #
        # @param [Mapper::RelationshipSet] relationship_set
        #   set of source model relationships
        #
        # @param [Hash{Class => Symbol}] relations
        #   a hash returned from {MapperRegistry#relation_map}
        #
        # @return [undefined]
        #
        # @api private
        def initialize(relationship, relationship_set, relations)
          @relationship     = relationship
          @relationship_set = relationship_set
          @relations        = relations
          @relation_names   = relation_names
        end

        # Iterate on all generated relation node names
        #
        # @return [self]
        #
        # @api private
        def each(&block)
          return to_enum unless block_given?
          @relation_names.each(&block)
          self
        end

        # Return all node names as connector names
        #
        # @return [Array<Symbol>]
        #
        # @api private
        def connector_names
          map(&:to_connector_name)
        end

        # Return the first name
        #
        # @return [NodeName, Symbol]
        #
        # @api private
        def first
          to_a.first
        end

        # Return the last name
        #
        # @return [NodeName, Symbol]
        #
        # @api private
        def last
          to_a.last
        end

        private

        # Generates an array of unique relation node names used to build a join
        #
        # @return [Array<NodeName>]
        #
        # @api private
        def relation_names(relationship_map = rel_map, joins = [])
          relationship_map.each do |right, left|
            if left.is_a?(Hash)
              joins << NodeName.new(relation_names(left, joins)[joins.size-1], *right)
            else
              joins << NodeName.new(left, *right)
            end
          end

          joins
        end

        # Generates a relationship map representing "via" hierarchy
        #
        # Hash is indexed with relation.name => relationship.name pairs
        # so that it's possible to generate connector names later on.
        #
        # @return [Hash]
        #
        # @api private
        def rel_map(rel = @relationship, rel_set = @relationship_set, map = {})
          name    = relations[rel.target_model]
          key     = [ name, rel.name ]
          via_rel = rel_set[rel.via]

          if via_rel.via
            map[key] = {}
            rel_map(via_rel, rel_set, map[key])
          else
            map.merge!(key => relations[via_rel.target_model])
          end

          map
        end

      end # class NodeNameSet

    end # class Builder
  end # class RelationRegistry
end # module DataMapper
