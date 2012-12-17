module DataMapper
  module Relation
    class Aliases

      class Index

        include Equalizer.new(:entries)

        attr_reader :entries
        attr_reader :header

        def initialize(entries, strategy)
          @entries  = entries
          @inverted = @entries.invert
          @header   = @entries.values.to_set
          @strategy = strategy.new(self)
        end

        def join(*args)
          @strategy.join(*args)
        end

        def rename(aliases)
          self.class.new(renamed_entries(aliases), @strategy.class)
        end

        def aliases(other)
          entries.each_with_object({}) { |(key, name), aliases|
            other_name = other[key]
            if name.field != other_name.name
              aliases[name.field] = other_name.name
            end
          }
        end

        def renamed_join_key_entries(join_definition)
          entries.each_with_object({}) { |(key, name), renamed|
            join_definition.each do |left_key, right_key|
              if name.field == left_key
                renamed[key] = aliased_field(right_key, name.prefix)
              end
            end
          }
        end

        # TODO refactor away the control couple
        def renamed_clashing_entries(other, join_definition, natural_join = true)
          entries.each_with_object({}) { |(key, name), renamed|
            if other.field?(name.field)
              if natural_join
                unless join_definition.key?(name.field)
                  renamed[key] = aliased_field(key.field, key.prefix, true)
                end
              else
                renamed[key] = aliased_field(key.field, key.prefix, true)
              end
            end
          }
        end

        def [](key)
          entries[key]
        end

        def field?(field)
          entries.values.any? { |name| name.field == field }
        end

        private

        def renamed_entries(aliases)
          aliases.each_with_object(entries.dup) { |(from, to), renamed|
            renamed[@inverted.fetch(from)] = to
          }
        end

        def aliased_field(*args)
          DataMapper::Mapper::Attribute.aliased_field(*args)
        end

      end # class Index

    end # class Aliases
  end # module Relation
end # module DataMapper
