module DataMapper
  class RelationRegistry

    class EdgeSet

      include Enumerable

      def initialize
        @entries = Set.new
      end

      def each
        return to_enum unless block_given?
        @entries.each { |entry| yield(entry) }
        self
      end

      def <<(edge)
        @entries.add?(edge) ? edge : find(edge)
      end

      def add(source, target)
        edge = Edge.new(source, target)
        self << edge
      end

      private

      def find(edge)
        @entries.detect { |e| e == edge }
      end
    end # class EdgeSet
  end # class RelationRegistry
end # module DataMapper
