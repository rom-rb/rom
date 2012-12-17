module DataMapper
  module Relation
    class Aliases
      class Strategy

        class InnerJoin < self

          private

          def index_entries(other_index, join_definition)
            index.entries.dup.
              update(clashing_entries(other_index, join_definition, false)).
              update(other_index.entries)
          end

        end # class InnerJoin

      end # class Strategy
    end # class Aliases
  end # module Relation
end # module DataMapper
