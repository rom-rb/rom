module DataMapper
  class Engine
    module Arel

      class Edge < Relation::Graph::Edge
        Attribute = Struct.new(:name)

        def initialize(*)
          super

          @target_aliases = target_node.aliases
          @source_aliases = source_node.aliases.join(@target_aliases, join_definition)

          @source_relation = source_node.gateway.relation
          @target_relation = target_node.gateway.relation

          @aliases = @source_aliases
        end

        # Builds a joined relation from source and target nodes
        #
        # @return [RelationNode::VeritasRelation]
        #
        # @api private
        def node(relationship, operation = relationship.operation)
          Node.new(name, join_relation(operation), @aliases)
        end

        private

        def join_relation(operation)
          relation = @source_relation.clone.join(@target_relation).on(left_key.eq(right_key)).order(left_key)
          relation = relation.instance_eval(&operation) if operation
          @source_node.gateway.new(relation, header)
        end

        def left_key
          left_key_name = join_definition.left.keys.first
          join_definition.left.relation[left_key_name]
        end

        def right_key
          right_key_name = join_definition.right.keys.first
          join_definition.right.relation[right_key_name]
        end

        def header
          @aliases.header.map { |attribute_alias|
            Attribute.new(
              "#{attribute_alias.prefix}.#{attribute_alias.field} AS #{attribute_alias}"
            )
          }
        end

      end # class Edge
    end # module Arel
  end # class Engine
end # module DataMapper
