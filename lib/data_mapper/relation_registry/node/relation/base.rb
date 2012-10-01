module DataMapper
  class RelationRegistry
    class Node
      class Relation < Node

        class Base < Node

          def initialize(relation)
            super

            @name = relation.name.to_sym
          end
        end # class Base
      end # class Relation
    end # class Node
  end # class RelationRegistry
end # module DataMapper
