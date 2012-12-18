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

        abstract_method :joined_entries

        private :joined_entries

        def join_key_entries(join_definition)
          with_entries { |key, name, new_entries|
            join_definition.each do |left_key, right_key|
              if name.field == left_key
                new_entries[key] = aliased_field(right_key, name.prefix)
              end
            end
          }
        end

        def aliased_field(*args)
          DataMapper::Mapper::Attribute.aliased_field(*args)
        end

        def new_index(*args)
          @index.class.new(*args)
        end

        def clashing_entries(index, join_definition)
          with_entries { |key, name, new_entries|
            if clashing?(name, index, join_definition)
              new_entries[key] = aliased_field(key.field, key.prefix, true)
            end
          }
        end

        def clashing?(name, index, _join_definition)
          index.field?(name.field)
        end

        def with_entries
          entries.each_with_object({}) { |(key, name), new_entries|
            yield(key, name, new_entries)
          }
        end

      end # class Strategy

    end # class Aliases
  end # module Relation
end # module DataMapper
