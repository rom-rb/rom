module Rom
  module Relation
    class Header
      class JoinStrategy

        # Renaming strategy for natural join operations. Renames
        # attributes join key attributes to match, and renames
        # attributes with clashing names to make sure they don't match.
        class NaturalJoin < self

          private

          def joined_entries(attribute_index)
            super.
              update(join_key_entries(attribute_index)).
              update(clashing_entries(attribute_index)).
              update(entries)
          end

          def clashing?(name)
            super && !join_definition.value?(name.field)
          end

        end # class NaturalJoin

      end # class JoinStrategy
    end # class Header
  end # module Relation
end # module Rom
