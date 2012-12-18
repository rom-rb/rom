module DataMapper
  module Relation
    class Aliases

      class Strategy

        include AbstractType

        def initialize(index)
          @index   = index
          @entries = @index.entries
        end

        def join(index, join_definition)
          new_index(joined_entries(index, join_definition.to_hash), self.class)
        end

        private

        attr_reader :entries

        def joined_entries(index, _join_definition)
          index.entries.dup
        end

        def join_key_entries(index, join_definition)
          with_index_entries(index) { |key, name, new_entries|
            join_definition.each do |left_key, right_key|
              if name.field == right_key
                new_entries[key] = aliased_field(left_key, name.prefix)
              end
            end
          }
        end

        def clashing_entries(index, join_definition)
          with_index_entries(index) { |key, name, new_entries|
            if clashing?(name, join_definition)
              new_entries[key] = aliased_field(key.field, key.prefix, true)
            end
          }
        end

        def clashing?(name, _join_definition)
          @index.field?(name.field)
        end

        def with_index_entries(index)
          index.entries.each_with_object({}) { |(key, name), new_entries|
            yield(key, name, new_entries)
          }
        end

        def aliased_field(*args)
          DataMapper::Mapper::Attribute.aliased_field(*args)
        end

        def new_index(*args)
          @index.class.new(*args)
        end

      end # class Strategy

    end # class Aliases
  end # module Relation
end # module DataMapper
