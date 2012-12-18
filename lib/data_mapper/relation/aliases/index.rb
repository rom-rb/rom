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
            other_name = other[key].name
            if name.field != other_name
              aliases[name.field] = other_name
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

      end # class Index

    end # class Aliases
  end # module Relation
end # module DataMapper
