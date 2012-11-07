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

      # TODO make this work
      #
      # include AbstractClass

      # Temporary helper to make this class abstract
      #
      # The abstract_class gem currently only supports
      # classes with Object as their superclass.
      #
      # TODO support this usecase in AbstractClass
      #
      # @return [undefined]
      #
      # @api private
      def self.new(*)
        if superclass.equal?(Graph::Node)
          raise NotImplementedError, "#{self} is an abstract class"
        else
          super
        end
      end

      include Enumerable, Equalizer.new(:name, :relation)

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
      #   tuple = { :id => 1, :name => 'John' }
      #   DataMapper.engines[:default].relations[:people] << tuple
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
