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
          left_key_name  = join_definition.left.keys.first
          right_key_name = join_definition.right.keys.first

          left_key =
            if @source_relation.is_a?(Arel::SelectManager)
              @source_relation.source.right.first.left[left_key_name]
            else
              @source_relation[left_key_name]
            end

          right_key = @target_relation[right_key_name]

          relation = @source_relation.join(@target_relation).on(left_key.eq(right_key)).order(left_key)

          if operation
            relation = relation.instance_eval(&operation)
          end

          # FIXME: @aliases should already include fields from both sides
          header = @aliases.to_hash.merge(@target_aliases.to_hash)

          @source_node.gateway.new(relation, header)
        end


        def node_class
          RelationNode::ArelRelation
        end
      end # class VeritasEdge
    end # class RelationEdge
  end # class RelationRegistry
end # module DataMapper
