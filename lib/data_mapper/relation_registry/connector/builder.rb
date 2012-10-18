module DataMapper
  class RelationRegistry
    class Connector

      class Builder

        def self.call(mappers, relations, relationship)
          left_mapper  = mappers[relationship.source_model]
          right_mapper = mappers[relationship.target_model]

          left_node =
            if relationship.via
              via_relationship = left_mapper.relationships[relationship.via]
              via_name         = :"#{left_mapper.relation.name}_#{via_relationship.name}"

              via_relation =
                if relations[via_name]
                  relations[via_name]
                else
                  call(mappers, relations, via_relationship).aliased_for(relationship)
                end.relation

              relations.build_node(via_name, via_relation)
            else
              relations.node_for(left_mapper.relation)
            end

          right_node =
            if via_relationship
              relations.node_for(right_mapper.relation).aliased_for(via_relationship)
            else
              relations.node_for(right_mapper.relation)
            end

          unless left_node && right_node
            raise ArgumentError, "Missing left and/or right nodes for #{relationship.name} left: #{left_node.inspect} right: #{right_node.inspect}"
          end

          relations.add_node(left_node)  unless relations[left_node.name]
          relations.add_node(right_node) unless relations[right_node.name]

          edge = relations.edges.detect { |e| e.name == relationship.name }

          unless edge
            edge = relations.build_edge(relationship.name, left_node, right_node)
            relations.add_edge(edge)
          end

          connector = Connector.new(edge, relationship)

          relations.add_connector(connector)

          connector
        end

      end # class Builder

    end # class RelationConnector
  end # class RelationRegistry
end # module DataMapper
