module DataMapper
  class RelationRegistry

    # Builds relation nodes + edges and a connector for a relationship
    #
    # @api private
    class Builder

      # Build new nodes, edges and a connector for +relationship+
      #
      # @see RelationNode
      # @see RelationEdge
      # @see Connector
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
      # @return [Builder]
      #
      # @api private
      def self.call(relations, mappers, relationship)
        new(relations, mappers, relationship)
      end

      private

      def initialize(relations, mappers, relationship)
        @relations    = relations
        @mappers      = mappers
        @relationship = relationship
        @node_names   = node_name_set

        build
      end

      def build
        build_connector(*build_relation_nodes)
      end

      def build_relation_nodes
        nodes = @node_names.map do |node_name|
          edge = build_edge(@relationship.name, *nodes(node_name))
          build_node(node_name, *build_relation(edge, relationship(node_name)))
        end

        [ @node_names.last, nodes.last ]
      end

      def build_edge(name, left, right)
        edge = @relations.edge_for(left, right)

        unless edge
          edge = @relations.build_edge(name, left, right, key_map(left, right))
          @relations.add_edge(edge)
        end

        edge
      end

      def build_relation(edge, relationship)
        node = edge.relation(relationship)

        [ relation(node, relationship), node.aliases ]
      end

      def build_node(name, relation, aliases)
        @relations.new_node(name, relation, aliases) unless @relations[name]
        @relations[name]
      end

      def build_connector(name, node)
        @relations.add_connector(connector(name, node))
      end

      def relation(node, relationship)
        operation = relationship.operation
        relation  = node.relation
        relation  = relation.instance_eval(&operation) if operation
        relation
      end

      def connector(name, node)
        Connector.new(name, node, @relationship, @relations)
      end

      def node_name_set
        NodeNameSet.new(@relationship, source_relationships, relation_map)
      end

      def key_map(left, right)
        JoinKeyMap.new(left, right, left_key, right_key)
      end

      def nodes(node_name)
        [ left_node(node_name), right_node(node_name) ]
      end

      def left_node(node_name)
        @relations[node_name.left]
      end

      def right_node(node_name)
        @relations[node_name.to_a.last] || @relations[node_name.right]
      end

      def left_key
        Array(@relationship.source_key)
      end

      def right_key
        Array(@relationship.target_key)
      end

      def source_mapper
        @mappers[@relationship.source_model]
      end

      def source_relationships
        source_mapper.relationships
      end

      def relationship(node_name)
        source_relationships[node_name.relationship.name]
      end

      def relation_map
        @mappers.relation_map
      end
    end # class Builder
  end # class RelationRegistry
end # module DataMapper
