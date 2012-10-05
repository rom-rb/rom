module DataMapper
  class RelationRegistry
    class Node
      class Relation < self

        class Base < Node

          def initialize(relation)
            super

            @name = relation.name.to_sym
          end

          def base_relation?
            true
          end
        end # class Base
      end # class Relation
    end # class Node
  end # class RelationRegistry
end # module DataMapper
