module DataMapper
  module Relation
    class Aliases
      class Strategy

        class InnerJoin < self

          private

          def joined_entries(attribute_index)
            super.
              update(clashing_entries(attribute_index)).
              update(entries)
          end

        end # class InnerJoin

      end # class Strategy
    end # class Aliases
  end # module Relation
end # module DataMapper
