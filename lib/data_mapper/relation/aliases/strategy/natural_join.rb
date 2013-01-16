module DataMapper
  module Relation
    class Aliases
      class Strategy

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

      end # class Strategy
    end # class Aliases
  end # module Relation
end # module DataMapper
