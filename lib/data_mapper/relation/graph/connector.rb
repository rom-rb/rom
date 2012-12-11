module DataMapper
  module Relation
    class Graph

      # Holds joined relation node and relationship used to create the join
      #
      # @api private
      class Connector

        # The connector's name
        #
        # @return [Symbol]
        #
        # @api private
        attr_reader :name

        # Joined relation node
        #
        # @return [Node]
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
        # @return [Graph]
        #
        # @api private
        attr_reader :relations

        attr_reader :registry

        # Initializes new connector instance
        #
        # @param [Node] node
        #   the node this connector must point to
        #
        # @param [Relationship] relationship
        #   the relationship backing the connector
        #
        # @param [Graph] relations
        #   the registry used to lookup relations
        #
        # @return [undefined]
        #
        # @api private
        def initialize(node, relationship, relations, registry)
          @node         = node
          @relationship = relationship
          @relations    = relations
          @registry     = registry
          @name         = connector_name(node.name)
        end

        def source_node
          @relations[source_mapper.relation_name]
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
        # @return [Node::Aliases]
        #
        # @api private
        def source_aliases
          @node.aliases
        end

        # Returns aliases for the target model
        #
        # @return [Node::Aliases]
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

        # Returns source mapper instance
        #
        # @return [Relation::Mapper]
        #
        # @api private
        def source_mapper
          registry[source_model]
        end

        # Returns target mapper instance
        #
        # @return [Relation::Mapper]
        #
        # @api private
        def target_mapper
          registry[target_model]
        end

        private

        def connector_name(node_name)
          :"#{node_name}__#{@relationship.name}"
        end

      end # class Connector

    end # class Graph
  end # module Relation
end # module DataMapper
