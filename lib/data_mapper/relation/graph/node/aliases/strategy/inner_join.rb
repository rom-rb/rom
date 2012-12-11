module DataMapper
  module Relation
    class Graph
      class Node
        class Aliases
          class Strategy

            class InnerJoin < self

              private

              def index_entries(other_index, join_definition)
                index.entries.dup.
                  update(clashing_entries(other_index, join_definition)).
                  update(other_index.entries)
              end

            end # class InnerJoin

          end # class Strategy
        end # class Aliases
      end # class Node
    end # class Graph
  end # module Relation
end # module DataMapper
