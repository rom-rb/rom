module DataMapper
  module Relation
    class Graph
      class Node

        class Aliases

          include Enumerable
          include Equalizer.new(:index)

          attr_reader :index
          attr_reader :header

          protected :index

          def initialize(index, aliases = {})
            @index   = index
            @aliases = aliases
            @header  = @index.header
          end

          def each(&block)
            return to_enum unless block_given?
            @aliases.each(&block)
            self
          end

          def join(other, join_definition)
            joined_index = index.join(other.index, join_definition)
            self.class.new(joined_index, index.aliases(joined_index))
          end

          def rename(aliases)
            self.class.new(index.rename(aliases), aliases)
          end

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
                renamed[key] = key
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

          class Strategy

            include AbstractType

            def initialize(index)
              @index = index
            end

            def join(index, join_definition)
              index.class.new(index_entries(index, join_definition.to_hash), self.class)
            end

            abstract_method :index_entries
            private :index_entries

            private

            attr_reader :index

            def join_key_entries(*args)
              index.renamed_join_key_entries(*args)
            end

            def clashing_entries(*args)
              index.renamed_clashing_entries(*args)
            end

            class InnerJoin < self

              private

              def index_entries(other_index, join_definition)
                index.entries.dup.
                  update(clashing_entries(other_index, join_definition)).
                  update(other_index.entries)
              end
            end

            class NaturalJoin < self

              private

              def index_entries(other_index, join_definition)
                index.entries.dup.
                  update(join_key_entries(join_definition)).
                  update(clashing_entries(other_index, join_definition)).
                  update(other_index.entries)
              end
            end # class NaturalJoin
          end # class Strategy
        end # class Aliases
      end # class Node
    end # class Graph
  end # module Relation
end # module DataMapper
