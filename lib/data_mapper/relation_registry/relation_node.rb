module DataMapper
  class RelationRegistry

    # Represents a relation in the registry graph
    #
    # @abstract
    #
    # TODO: add #update
    # TODO: add #delete
    #
    class RelationNode < Graph::Node
      include Enumerable, Equalizer.new(:name)

      # Instance of the engine's relation class
      #
      # @return [Object]
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
      # @param [Aliases]
      #
      # @return [undefined]
      #
      # @api private
      def initialize(name, relation, aliases = {})
        super(name)
        @relation = relation
        @aliases  = aliases
      end

      # Iterate on relation
      #
      # @example
      #
      #   DataMapper.engines[:default].relations[:people].each do |tuple|
      #     puts tuple.inspect
      #   end
      #
      # @return [self, Enumerator]
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
      # @example
      #
      #   tuple = { :name => 'John' }
      #   DataMapper.engines[:postgres].relations[:people].insert(tuple)
      #
      # @param [Object]
      #
      # @api public
      def insert(tuple)
        @relation.insert(tuple)
      end
      alias_method :<<, :insert

      # Deletes an object identified with the given key from the relation
      #
      # @example
      #
      #   DataMapper.engines[:postgres].relations[:people].delete(1)
      #
      # @param [Object] key attribute
      #
      # @api public
      def delete(key)
        @relation.delete(key)
      end

    end # class RelationNode

  end # class RelationRegistry
end # module DataMapper
