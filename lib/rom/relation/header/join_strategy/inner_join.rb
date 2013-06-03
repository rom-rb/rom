module ROM
  module Relation
    class Header
      class JoinStrategy

        # Renaming strategy for inner join operations. Only renames
        # attributes with clashing names.
        class InnerJoin < self

          private

          def joined_entries(attribute_index)
            super.
              update(clashing_entries(attribute_index)).
              update(entries)
          end

        end # class InnerJoin

      end # class JoinStrategy
    end # class Header
  end # module Relation
end # module ROM
