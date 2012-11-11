module DataMapper
  class RelationRegistry

    # Builds relation nodes for relationships
    #
    # @abstract
    #
    # @api private
    class Builder

      # Build a new {RelationNode} and {Connector} for +relationship+
      #
      # @param [RelationRegistry] relations
      #   a registry of relations
      #
      # @param [MapperRegistry] mappers
      #   a registry of mappers
      #
      # @param [Relationship] relationship
      #   the relationship the connector is built for
      #
      # @return [BaseBuilder, ViaBuilder]
      #
      # @api private
      def self.call(relations, mappers, relationship)
        new(relations, mappers, relationship)
      end

      private

      # The {RelationRegistry} used by this builder
      #
      # @return [RelationRegistry]
      #
      # @api private
      attr_reader :relations

      # The {MapperRegistry} used by this builder
      #
      # @return [MapperRegistry]
      #
      # @api private
      attr_reader :mappers

      # The relationship to build the {RelationNode} and {Connector} for
      #
      # @see RelationNode
      # @see Connector
      #
      # @return [Relationship]
      #
      # @api private
      attr_reader :relationship

      # The {Connector} built for {#relationship}
      #
      # @return [Connector]
      #
      # @api private
      attr_reader :connector

      # Initialize a new {Builder} instance
      #
      # @param [RelationRegistry] relations
      #   the registry of relations
      #
      # @param [MapperRegistry] mappers
      #   the registry of mappers
      #
      # @param [Relationship] relationship
      #   the relationship the connector is built for
      #
      # @return [undefined]
      #
      # @api private
      def initialize(relations, mappers, relationship)
        @relations, @mappers, @relationship = relations, mappers, relationship
        initialize_nodes
        @connector = RelationRegistry::Connector.new(name, node, relationship, relations)
        relations.add_connector(@connector)
      end

      # @api private
      def build_relation(edge, relationship = @relationship)
        node      = edge.relation(relationship)
        operation = relationship.operation
        relation  = node.relation
        relation  = relation.instance_eval(&operation) if operation
        [ relation, node.aliases ]
      end

      # @api private
      def build_node(name, relation, aliases)
        relations.new_node(name, relation, aliases) unless relations[name]
        relations[name]
      end

      # @api private
      def build_edge(name = relationship.name, left = left_node, right = right_node)
        edge = relations.edge_for(left, right)

        unless edge
          source_key   = Array(relationship.source_key)
          target_key   = Array(relationship.target_key)
          join_key_map = JoinKeyMap.new(left, right, source_key, target_key)

          edge = relations.build_edge(name, left, right, join_key_map)
          relations.add_edge(edge)
        end

        edge
      end

      # @api private
      def initialize_nodes
        @node_names = NodeNameSet.new(
          relationship,
          mappers[relationship.source_model].relationships,
          mappers.relation_map
        )

        build_relations
      end

      # @api private
      def build_relations
        @nodes = @node_names.map do |node_name|
          left_name, right_name = node_name.to_a

          left_node  = relations[left_name]
          right_node = relations[right_name] || relations[node_name.right]

          node_relationship = mappers[relationship.source_model].relationships[node_name.relationship.name]
          edge              = build_edge(relationship.name, left_node, right_node)
          relation, aliases = build_relation(edge, node_relationship)

          build_node(node_name, relation, aliases)
        end
      end

      # @api private
      def node
        @nodes.last
      end

      # @api private
      def name
        @node_names.last
      end

      # The relationship's source model relation name
      #
      # @return [Symbol]
      #
      # @api private
      def left_name
        @node_names.last.left
      end

      # The relationship's target model relation name
      #
      # @return [Symbol]
      #
      # @api private
      def right_name
        @node_names.last.right
      end

      # The relationship's source relation node
      #
      # @return [RelationNode]
      #
      # @api private
      def left_node
        relations[left_name]
      end

      # The relationship's target relation node
      #
      # @return [RelationNode]
      #
      # @api private
      def right_node
        relations[right_name]
      end
    end # class Builder
  end # class RelationRegistry
end # module DataMapper
