module DataMapper
  module Relation
    class Graph
      class Connector

        # Builds relation nodes + edges and a connector for a relationship
        #
        # @api private
        class Builder

          # Build new node(s), edge(s) and a connector for +relationship+
          #
          # @see Graph::Node
          # @see Graph::Edge
          # @see Graph::Connector
          #
          # @param [Graph] relations
          #   a registry of relations
          #
          # @param [DataMapper::Mapper::Registry] mappers
          #   a registry of mappers
          #
          # @param [DataMapper::Relationship] relationship
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
            @node_name_set = node_name_set(@relationship, @mappers)

            connect
          end

          def connect
            nodes = connect_nodes
            add_connector(nodes.last)
          end

          def connect_nodes
            @node_name_set.map { |node_name|
              add_node(node_name, add_edge(node_name, *nodes(node_name)))
            }
          end

          def add_node(node_name, edge)
            node = edge.node(node_name.relationship, operation(node_name))
            @relations.add_node(node)
            node
          end

          def add_edge(node_name, left, right)
            edge = @relations.build_edge(node_name, left, right)
            @relations.add_edge(edge)
            edge
          end

          def add_connector(node)
            @relations.add_connector(connector(node))
          end

          def connector(node)
            Connector.new(node, @relationship, @relations, @mappers)
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
            @mappers[node_name.target_model]
          end

          def operation(node_name)
            target_node?(node_name) ? @relationship.operation : node_name.operation
          end

          def target_node?(node_name)
            @node_name_set.last == node_name
          end

          def node_name_set(relationship, mappers)
            Graph::Node::NameSet.new(@relationship, @mappers)
          end

        end # class Builder

      end # class Connector
    end # class Graph
  end # module Relation
end # module DataMapper
