module DataMapper
  class RelationRegistry

    # TODO: add all methods for CRUD
    class RelationNode < Graph::Node
      include Enumerable, Equalizer.new(:name, :relation)

      attr_reader :relation
      attr_reader :aliases

      # TODO: add specs
      def initialize(name, relation, aliases = nil)
        super(name)
        @relation = relation
        @aliases  = aliases || {}
      end

      # @api public
      # TODO: add specs
      def each(&block)
        @relation.each(&block)
      end

      # @api public
      # TODO: add specs
      def <<(object)
        @relation << object
      end

    end # class RelationNode

  end # class RelationRegistry
end # module DataMapper
