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
        def relation_names
          names = []
          rel_map.each { |pair| names << NodeName.new(names.last || source, *pair) }
          names
        end

        # @api private
        def source
          relations[@relationship.source_model]
        end

        # @api private
        def rel_map(relationship = @relationship, relationships = [])
          via = @relationship_set[relationship.through]
          rel_map(via, relationships) if via
          relationships << [ relations[relationship.target_model], relationship ]
          relationships
        end

      end # class NodeNameSet

    end # class Builder
  end # class RelationRegistry
end # module DataMapper
