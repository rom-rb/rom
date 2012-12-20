module DataMapper
  module Relation
    class Aliases
      class Strategy

        class NaturalJoin < self

          private

          def joined_entries(index, join_definition, relation_aliases)
            super.
              update(join_key_entries(index, join_definition, relation_aliases)).
              update(clashing_entries(index, join_definition, relation_aliases)).
              update(entries)
          end

          def clashing?(name, join_definition)
            super && !join_definition.value?(name.field)
          end

        end # class NaturalJoin

      end # class Strategy
    end # class Aliases
  end # module Relation
end # module DataMapper
