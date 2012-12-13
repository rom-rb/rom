module DataMapper
  module Relation
    class Graph
      class Node
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
                other_name    = other[key]
                aliases[name] = other_name if name != other_name
              }
            end

            def renamed_join_key_entries(join_definition)
              entries.each_with_object({}) { |(key, name), renamed|
                join_definition.each do |left_key, right_key|
                  renamed[key] = right_key if name == left_key
                end
              }
            end

            def renamed_clashing_entries(other, join_definition)
              entries.each_with_object({}) { |(key, name), renamed|
                next if !other.include?(name) || join_definition.key?(name)
                renamed[key] = key.name
              }
            end

            def [](key)
              entries[key]
            end

            def include?(name)
              entries.value?(name)
            end

            private

            def renamed_entries(aliases)
              aliases.each_with_object(entries.dup) { |(from, to), renamed|
                renamed[@inverted.fetch(from)] = to
              }
            end

          end # class Index

        end # class Aliases
      end # class Node
    end # class Graph
  end # module Relation
end # module DataMapper
