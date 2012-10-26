module DataMapper
  class RelationRegistry

    # Builds relation nodes for relationships
    #
    class Builder

      attr_reader :relations
      attr_reader :mappers
      attr_reader :relationship

      attr_reader :connector

      # @api private
      def self.call(relations, mappers, relationship)
        new(relations, mappers, relationship)
      end

      # @api private
      def initialize(relations, mappers, relationship)
        @relations, @mappers, @relationship = relations, mappers, relationship

        left_name = mappers[relationship.source_model].class.relation_name

        @node_names = if relationship.via
                        NodeNameSet.new(relationship, mappers[relationship.source_model].relationships)
                      else
                        [ NodeName.new(left_name, relationship.name) ]
                      end

        relationship_relations = build_relations

        node = if relationship.via
          right_name = @node_names.last.left_of(left_name)
          right_node = relations[right_name]
          left_node  = relations[left_name]

          node_name = NodeName.new(left_name, right_name)
          edge      = relations.build_edge(node_name, left_node, right_node)
          relation  = edge.relation

          if relationship.operation
            relation = relation.instance_eval(&relationship.operation)
          end

          node = relations.build_node(node_name, relation)
          relations.add_edge(edge).add_node(node)
          node
        else
          relationship_relations.first
        end

        connector_name = @node_names.last
        @connector     = RelationRegistry::Connector.new(
          connector_name.to_sym, node, relationship, relations)

        relations.add_connector(connector_name, @connector)
      end

      def build_relations
        @node_names.map do |node_name|
          left  = node_name.left
          right = node_name.right

          left_node  = relations[left]  || relations[mappers[relationship.source_model].class.relation_name]
          right_node = relations[right] || relations[mappers[relationship.target_model].class.relation_name]

          unless relations[node_name]
            edge     = relations.build_edge(node_name, left_node, right_node)
            relation = edge.relation

            if @node_names.is_a?(Array) && relationship.operation
              relation = relation.instance_eval(&relationship.operation)
            end

            node = relations.build_node(node_name, relation)
            relations.add_edge(edge).add_node(node)
            node
          else
            relations[node_name]
          end
        end
      end
    end

  end # class RelationRegistry
end # module DataMapper
