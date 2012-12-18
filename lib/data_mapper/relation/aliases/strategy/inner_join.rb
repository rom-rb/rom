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

          def clashing_entries(index, join_definition)
            entries.each_with_object({}) { |(key, name), renamed|
              if clash?(index, name)
                renamed[key] = aliased_field(key.field, key.prefix, true)
              end
            }
          end

        end # class InnerJoin

      end # class Strategy
    end # class Aliases
  end # module Relation
end # module DataMapper
