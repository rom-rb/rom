module DataMapper
  class RelationRegistry

    # Holds joined relation node and relationship used to create the join
    #
    # @api private
    class Connector

      # Name of the joined relation
      #
      # @return [Symbol]
      #
      # @api private
      attr_reader :name

      # Joined relation node
      #
      # @return [RelationNode]
      #
      # @api private
      attr_reader :node

      # Relationship object
      #
      # @return [Relationship]
      #
      # @api private
      attr_reader :relationship

      # Relation registry
      #
      # @return [RelationRegistry]
      #
      # @api private
      attr_reader :relations

      # Initializes new connector instance
      #
      # @param [Symbol]
      #
      # @param [RelationNode]
      #
      # @param [Relationship]
      #
      # @param [RelationRegistry]
      #
      # @return [undefined]
      #
      # @api private
      def initialize(name, node, relationship, relations)
        @name         = name.to_sym
        @node         = node
        @relationship = relationship
        @relations    = relations
      end

      # Returns source model of the relationship
      #
      # @return [Class]
      #
      # @api private
      def source_model
        relationship.source_model
      end

      # Returns target model of the relationship
      #
      # @return [Class]
      #
      # @api private
      def target_model
        relationship.target_model
      end

      # Returns aliases for the source model
      #
      # @return [AliasSet]
      #
      # @api private
      def source_aliases
        relations[source_mapper.relation_name].aliases
      end

      # Returns aliases for the target model
      #
      # @return [AliasSet]
      #
      # @api private
      def target_aliases
        relations[target_mapper.relation_name].aliases
      end

      # Returns if the relationship has collection target
      #
      # @return [Boolean]
      #
      # @api private
      def collection_target?
        relationship.collection_target?
      end

      private

      # Returns source mapper instance
      #
      # @return [Mapper::Relation]
      #
      # @api private
      def source_mapper
        DataMapper[source_model]
      end

      # Returns target mapper instance
      #
      # @return [Mapper::Relation]
      #
      # @api private
      def target_mapper
        DataMapper[target_model]
      end

    end # class Connector

  end # class RelationRegistry
end # module DataMapper
