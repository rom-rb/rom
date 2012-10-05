module DataMapper
  class RelationRegistry
    class Node

      class Relation < Node

        attr_reader :aliasing

        def initialize(relation, aliasing)
          super(relation)

          @aliasing = aliasing
          @name     = @aliasing.node_name
        end

        def aliases(edge_side)
          aliasing.aliases(edge_side)
        end

        # TODO find a better name
        def aliased(attribute_names)
          aliasing.aliased(attribute_names)
        end
      end # class Relation
    end # class Node
  end # class RelationRegistry
end # module DataMapper
