module DataMapper
  class RelationRegistry

    # Builds relation nodes + edges and a connector for a relationship
    #
    # @api private
    class Builder

      # Build new node(s), edge(s) and a connector for +relationship+
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
        @relations     = relations
        @mappers       = mappers
        @relationship  = relationship
        @node_name_set = NodeNameSet.new(@relationship, @mappers)

        build
      end

      def build
        nodes = @node_name_set.map { |node_name|
          left, right  = nodes(node_name)
          relationship = node_name.relationship

          edge = build_edge(node_name, left, right)
          node = edge.node(relationship, operation(relationship, node_name))

          @relations.add_node(node)

          node
        }

        build_connector(nodes.last)
      end

      def operation(relationship, node_name)
        last_join = @node_name_set.last == node_name
        last_join ? @relationship.operation : relationship.operation
      end

      def build_edge(node_name, left, right)
        edge = @relations.edge_for(node_name)

        unless edge
          edge = @relations.build_edge(node_name, left, right)
          @relations.add_edge(edge)
        end

        edge
      end

      def build_connector(node)
        @relations.add_connector(connector(node))
      end

      def connector(node)
        Connector.new(node, @relationship, @relations)
      end

      def nodes(node_name)
        [ left_node(node_name), right_node(node_name) ]
      end

      def left_node(node_name)
        @relations[node_name.left]
      end

      def right_node(node_name)
        @relations[node_name.right] || target_mapper(node_name).relation
      end

      def target_mapper(node_name)
        @mappers[node_name.relationship.target_model]
      end
    end # class Builder
  end # class RelationRegistry
end # module DataMapper
