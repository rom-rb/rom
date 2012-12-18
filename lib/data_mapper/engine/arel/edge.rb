module DataMapper
  class Engine
    module Arel

      class Edge < Relation::Graph::Edge
        Attribute = Struct.new(:name)

        # Builds a joined relation from source and target nodes
        #
        # @return [Node]
        #
        # @api private
        def node(relationship, operation = relationship.operation)
          Node.new(name, join_relation(operation), aliases)
        end

        private

        def join_relation(operation)
          relation = source_relation.join(target_relation, left_key.eq(right_key)).order(left_key)
          relation = operation.call(relation, target_relation) if operation
          relation.project(header)
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
          aliases.header.map { |attribute_alias|
            Attribute.new(
              "#{attribute_alias.prefix}.#{attribute_alias.field} AS #{attribute_alias.name}"
            )
          }
        end

      end # class Edge
    end # module Arel
  end # class Engine
end # module DataMapper
