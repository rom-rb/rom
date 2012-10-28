module DataMapper

  # Abstract class for DataMapper engines
  #
  # @abstract
  class Engine

    # Returns db adapter used by the engine
    #
    # @api public
    attr_reader :adapter

    # Returns a relation registry used by the engine
    #
    # @return [DataMapper::RelationRegistry]
    #
    # @api public
    attr_reader :relations

    # Initializes an engine instance
    #
    # @param [String] db connection URI
    #
    # @return [undefined]
    #
    # @api private
    def initialize(uri = nil)
      @uri       = uri
      @relations = RelationRegistry.new(self)
    end

    # Returns relation node class that is used in the relation registry
    #
    # @example
    #   DataMapper::Engine.relation_node_class #= RelationRegistry::RelationNode
    #
    # @return [Class]
    #
    # @api public
    def relation_node_class
      RelationRegistry::RelationNode
    end

    # Returns relation edge class that is used in the relation registry
    #
    # @example
    #   DataMapper::Engine.relation_edge_class #= RelationRegistry::RelationEdge
    #
    # @return [Class]
    #
    # @api public
    def relation_edge_class
      RelationRegistry::RelationEdge
    end

    # Builds a relation instance that will be wrapped in a relation node
    #
    # @param [Symbol] name
    #
    # @abstract
    #
    # @api public
    def base_relation(name)
      raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
    end

    # Returns a gateway relation instance
    #
    # This is optional and by default it just returns the given relation back.
    # Currently it's only here for VeritasEngine. Most of the engines won't need
    # to override it.
    #
    # @param [Object] relation
    #
    # @api public
    def gateway_relation(relation)
      relation
    end

  end # class Engine
end # module DataMapper
