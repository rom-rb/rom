module DataMapper
  class RelationRegistry

    # Represents a relation in the registry graph
    #
    # TODO: add #update
    # TODO: add #delete
    #
    class RelationNode < Graph::Node
      include Enumerable, Equalizer.new(:name, :relation)

      # Instance of the engine's relation class
      #
      # @retun [Object]
      #
      # @api private
      attr_reader :relation

      # Aliases for this relation
      #
      # @return [AliasSet]
      #
      # @api private
      attr_reader :aliases

      # Initializes a relation node instance
      #
      # @param [Symbol,#to_sym]
      # @param [Object] relation from engine
      # @param [AliasSet]
      #
      # @return [undefined]
      #
      # @api private
      def initialize(name, relation, aliases = nil)
        super(name)
        @relation = relation
        @aliases  = aliases || {}
      end

      # Iterate on relation
      #
      # @return [self,#to_num]
      #
      # @yield [Object]
      #
      # @api public
      def each(&block)
        return to_enum unless block_given?
        @relation.each(&block)
        self
      end

      # Adds new object to the relation
      #
      # @param [Object]
      #
      # @return [self]
      #
      # @api public
      def <<(object)
        @relation << object
        self
      end

    end # class RelationNode

  end # class RelationRegistry
end # module DataMapper
