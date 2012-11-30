module DataMapper
  class RelationRegistry
    class RelationEdge < Graph::Edge

      class ArelEdge < self

        def initialize(*)
          super

          @target_aliases = target_node.aliases
          @source_aliases = source_node.aliases.join(@target_aliases, join_definition)

          @source_relation = source_node.gateway.relation.clone
          @target_relation = target_node.gateway.relation

          @aliases = @source_aliases
        end

        # Builds a joined relation from source and target nodes
        #
        # @return [RelationNode::VeritasRelation]
        #
        # @api private
        def node(relationship, operation = relationship.operation)
          node_class.new(name, join_relation(operation), @aliases)
        end

        private

        def join_relation(operation)
          left_key  = join_definition.left.keys.first
          right_key = join_definition.right.keys.first

          relation = @source_relation.join(@target_relation).
            on(@source_relation[left_key].eq(@target_relation[right_key])).
            order(@source_relation[left_key])

          if operation
            relation = relation.instance_eval(&operation)
          end

          # FIXME: @aliases should already include fields from both sides
          header = @aliases.to_hash.merge(@target_aliases)

          @source_node.gateway.new(relation, header)
        end


        def node_class
          RelationNode::ArelRelation
        end
      end # class VeritasEdge
    end # class RelationEdge
  end # class RelationRegistry
end # module DataMapper
