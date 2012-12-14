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

        end # class Aliases

      end # class Node
    end # class Graph
  end # module Relation
end # module DataMapper
