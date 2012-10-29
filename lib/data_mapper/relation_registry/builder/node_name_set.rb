module DataMapper
  class RelationRegistry
    class Builder

      # Set of relation names for a given relationship
      #
      class NodeNameSet
        include Enumerable

        # @api private
        attr_reader :relations

        # Initializes a node name set
        #
        # @param [DataMapper::Relationship]
        # @param [DataMapper::Mapper::RelationshipSet] set of source model relationships
        # @param [Hash<Class => Symbol>] a mode => relation_name map returned by mapper registry
        #
        # @return [undefined]
        #
        # @api private
        def initialize(relationship, registry, relations)
          @relationship, @registry, @relations = relationship, registry, relations
          @names = initialize_names
        end

        # Iterate on all generated relation node names
        #
        # @api private
        def each(&block)
          return to_enum unless block_given?
          @names.each(&block)
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
        # @return [DataMapper::RelationRegistry::Builder::NodeName,Symbol]
        #
        # @api private
        def first
          to_a.first
        end

        # Return the last name
        #
        # @return [DataMapper::RelationRegistry::Builder::NodeName,Symbol]
        #
        # @api private
        def last
          to_a.last
        end

        private

        # Generates an array of unique relation node names used to build a join
        #
        # @return [Array<DataMapper::RelationRegistry::Builder::NodeName]
        #
        # @api private
        def initialize_names(relationships = relationship_map, joins = [])
          relationships.each do |right, left|
            if left.is_a?(Hash)
              joins << NodeName.new(initialize_names(left, joins)[joins.size-1], *right)
            else
              joins << NodeName.new(left, *right)
            end
          end

          joins
        end

        # Generates a relationship map representing "via" hierarchy
        #
        # Hash is indexed with relation.name-relationship.name pairs so that
        # it's possible to generate connector names later on.
        #
        # @return [Hash]
        #
        # @api private
        def relationship_map(relationship = @relationship, registry = @registry, map = {})
          name             = relations[relationship.target_model]
          key              = [ name, relationship.name ]
          via_relationship = registry[relationship.via]

          if via_relationship.via
            map[key] = {}
            relationship_map(via_relationship, registry, map[key])
          else
            map.merge!(key => relations[via_relationship.target_model])
          end

          map
        end

      end # class NodeNameSet

    end # class Builder
  end # class RelationRegistry
end # module DataMapper
