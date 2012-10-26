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

        left_name  = mappers[relationship.source_model].class.relation_name
        right_name = mappers[relationship.target_model].class.relation_name

        relations_map = mappers.each_with_object({}) { |(id, mapper), hash|
          hash[mapper.class.model] = mapper.class.relation_name
        }

        @node_names = if relationship.via
                        NodeNameSet.new(relationship, mappers[relationship.source_model].relationships, relations_map)
                      else
                        [ NodeName.new(left_name, right_name, relationship.name) ]
                      end

        build_relations

        left_node  = relations[left_name]
        right_node = relations[relationship.via ? @node_names.last : @node_names.last.right]

        node_name = if relationship.via
                      NodeName.new(left_name, @node_names.last.to_connector_name)
                    else
                      @node_names.last.to_connector_name
                    end

        edge = relations.edge_for(left_node, right_node)

        unless edge
          edge = relations.build_edge(node_name, left_node, right_node)
          relations.add_edge(edge)
        end

        relation = edge.relation

        if relationship.operation
          relation = relation.instance_eval(&relationship.operation)
        end

        unless relations[node_name]
          node = relations.build_node(node_name, relation)
          relations.add_node(node)
        else
          node = relations[node_name]
        end

        @connector = RelationRegistry::Connector.new(node_name.to_sym, node, relationship, relations)

        relations.add_connector(@connector)
      end

      def build_relations
        @node_names.each do |node_name|
          left  = node_name.left
          right = node_name.right

          left_node  = relations[left]
          right_node = relations[right]

          unless relations[node_name]
            edge = relations.edges.detect { |e| e.name == node_name.to_sym }

            unless edge
              edge = relations.build_edge(node_name, left_node, right_node)
              relations.add_edge(edge)
            end

            relations.new_node(node_name, edge.relation)
          end
        end
      end
    end

  end # class RelationRegistry
end # module DataMapper
