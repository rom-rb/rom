module DataMapper
  class RelationRegistry
    class Builder

      # Builds relation nodes for relationships
      #
      class ViaBuilder < self
        attr_reader :node_names

        # @api private
        def initialize(relations, mappers, relationship)
          super

          relations_map = mappers.each_with_object({}) { |(id, mapper), map|
            map[mapper.class.model] = mapper.class.relation_name
          }

          @node_names = NodeNameSet.new(
            relationship,
            mappers[relationship.source_model].relationships,
            relations_map
          )

          build_relations

          edge     = build_edge
          relation = build_relation(edge)
          node     = build_node(name, relation)

          @connector = RelationRegistry::Connector.new(name, node, relationship, relations)
          relations.add_connector(@connector)
        end

        # @api private
        def name
          @name ||= NodeName.new(left_name, node_names.last.to_connector_name)
        end

        # @api private
        def right_node
          relations[node_names.last]
        end

        private

        def build_relations
          node_names.each do |node_name|
            left  = node_name.left
            right = node_name.right

            left_node  = relations[left]
            right_node = relations[right]

            edge     = build_edge(node_name, left_node, right_node)
            node_rel = mappers[relationship.source_model].relationships[node_name.relationship_name]
            relation = build_relation(edge, node_rel)

            build_node(node_name, relation)
          end
        end

      end # class ViaBuilder

    end # class Builder
  end # class RelationRegistry
end # module DataMapper
