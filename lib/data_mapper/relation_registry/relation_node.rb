module DataMapper
  class RelationRegistry

    class RelationNode < Graph::Node
      include Enumerable

      include Equalizer.new(:name, :relation)

      attr_reader :relation
      attr_reader :aliases

      def initialize(name, relation, aliases = nil)
        super(name)
        @relation = relation
        @aliases  = aliases || {}
      end

    end # class RelationNode

  end # class RelationRegistry
end # module DataMapper
