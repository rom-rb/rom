module DataMapper
  module Relation
    class Aliases
      class Strategy

        class InnerJoin < self

          private

          def joined_entries(other_index, join_definition)
            entries.dup.
              update(renamed_clashing_entries(other_index, join_definition)).
              update(other_index.entries)
          end

          def renamed_clashing_entries(other_index, join_definition)
            entries.each_with_object({}) { |(key, name), renamed|
              if other_index.field?(name.field)
                renamed[key] = aliased_field(key.field, key.prefix, true)
              end
            }
          end

        end # class InnerJoin

      end # class Strategy
    end # class Aliases
  end # module Relation
end # module DataMapper
