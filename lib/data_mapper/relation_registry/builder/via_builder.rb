module DataMapper
  class RelationRegistry
    class Builder

      # Builds relation nodes for relationships
      #
      class ViaBuilder < self
        attr_reader :node_names

        # @api private
        def name
          @name ||= NodeName.new(left_name, node_names.last.to_connector_name)
        end

        # @api private
        def right_node
          relations[node_names.last]
        end

        private

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
          node_names.each do |node_name|
            left  = node_name.left
            right = node_name.right

            left_node  = relations[left]
            right_node = relations[right]

            node_rel = mappers[relationship.source_model].relationships[node_name.relationship_name]
            edge     = build_edge(relationship.name, left_node, right_node)
            relation = build_relation(edge, node_rel)

            build_node(node_name, relation)
          end
        end

      end # class ViaBuilder

    end # class Builder
  end # class RelationRegistry
end # module DataMapper
