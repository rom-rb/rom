module DataMapper
  module Relation
    class Graph
      class Node
        class Aliases

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

          end # class Strategy

        end # class Aliases
      end # class Node
    end # class Graph
  end # module Relation
end # module DataMapper
