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
      end # class Relation
    end # class Node
  end # class RelationRegistry
end # module DataMapper
