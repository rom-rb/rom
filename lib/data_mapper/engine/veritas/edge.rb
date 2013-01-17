module DataMapper
  class Engine
    module Veritas

      class Edge < Relation::Graph::Edge

        # Builds a joined relation from source and target nodes
        #
        # @return [Node]
        #
        # @api private
        def node(relationship, operation = relationship.operation)
          Node.new(name, join_relation(operation), header)
        end

        private

        def join_relation(operation)
          relation = source_relation.join(target_relation)
          relation = relation.instance_eval(&operation) if operation
          relation
        end

        def target_relation
          super.rename(header.aliases)
        end

      end # class Edge

    end # module Veritas
  end # class Engine
end # module DataMapper
