module DataMapper
  module Relation
    class Aliases
      class Strategy

        class InnerJoin < self

          private

          def joined_entries(index, join_definition)
            entries.dup.
              update(clashing_entries(index, join_definition)).
              update(index.entries)
          end

        end # class InnerJoin

      end # class Strategy
    end # class Aliases
  end # module Relation
end # module DataMapper
