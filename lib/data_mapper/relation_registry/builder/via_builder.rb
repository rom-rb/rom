module DataMapper
  class RelationRegistry
    class Builder

      # Builds relation nodes for relationships
      #
      class ViaBuilder < self

        # The {NodeNameSet} built for +relationship+
        #
        # @return [NodeNameSet]
        #
        # @api private
        attr_reader :node_names

        # The name of the built {RelationNode}
        #
        # @return [NodeName]
        #
        # @api private
        def name
          @name ||= NodeName.new(left_name, node_names.last)
        end

        # The relationship's target relation name
        #
        # @see Builder#right_name
        #
        # @return [Symbol]
        #
        # @api private
        def right_name
          node_names.last
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
            left_name, right_name = node_name.to_a

            left_node  = relations[left_name]
            right_node = relations[right_name] || relations[node_name.right]

            node_relationship = mappers[relationship.source_model].relationships[node_name.relationship.name]
            edge              = build_edge(relationship.name, left_node, right_node)
            relation, aliases = build_relation(edge, node_relationship)

            build_node(node_name, relation, aliases)
          end
        end

      end # class ViaBuilder

    end # class Builder
  end # class RelationRegistry
end # module DataMapper
