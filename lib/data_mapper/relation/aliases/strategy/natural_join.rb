module DataMapper
  module Relation
    class Aliases
      class Strategy

        class NaturalJoin < self

          private

          def joined_entries(index, join_definition)
            super.
              update(join_key_entries(join_definition)).
              update(clashing_entries(index, join_definition)).
              update(index.entries)
          end

          def clashing?(name, index, join_definition)
            super && !join_definition.key?(name.field)
          end

        end # class NaturalJoin

      end # class Strategy
    end # class Aliases
  end # module Relation
end # module DataMapper
