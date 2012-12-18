module DataMapper
  module Relation
    class Aliases
      class Strategy

        class NaturalJoin < self

          private

          def joined_entries(index, join_definition)
            entries.dup.
              update(join_key_entries(join_definition)).
              update(clashing_entries(index, join_definition)).
              update(index.entries)
          end

          def clashing_entries(index, join_definition)
            renamed_entries { |key, name, renamed|
              if clash?(index, name) && !join_definition.key?(name.field)
                renamed[key] = aliased_field(key.field, key.prefix, true)
              end
            }
          end

        end # class NaturalJoin

      end # class Strategy
    end # class Aliases
  end # module Relation
end # module DataMapper
