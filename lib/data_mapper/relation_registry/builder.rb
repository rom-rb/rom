module DataMapper
  class RelationRegistry

    # Builds relation nodes for relationships
    #
    class Builder

      attr_reader :relations
      attr_reader :mappers
      attr_reader :relationship

      attr_reader :node
      attr_reader :edge

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

        @node = if relationship.via
          right_name = @node_names.last.left_of(left_name)
          right_node = relations[right_name]
          left_node  = relations[left_name]

          name  = NodeName.new(left_name, right_name)
          @edge = relations.build_edge(relationship, left_node, right_node)
          node  = relations.build_node(name, edge.relation)

          relations.add_edge(edge).add_node(node)

          node
        else
          relationship_relations.first
        end
      end

      def build_relations
        @node_names.map do |node_name|
          left  = node_name.left
          right = node_name.right

          left_node  = relations[left]  || relations[mappers[relationship.source_model].class.relation_name]
          right_node = relations[right] || relations[mappers[relationship.target_model].class.relation_name]

          unless relations[node_name]
            rel   = mappers[relationship.source_model].relationships[right]
            @edge = relations.build_edge(rel, left_node, right_node)
            node  = relations.build_node(node_name, edge.relation)

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
