module DataMapper

  # Abstract class for DataMapper engines
  #
  # @abstract
  class Engine
    include AbstractType

    MissingEngineError = Class.new(StandardError)

    # Returns database connection URI
    #
    # @return [Addressable::URI]
    #
    # @api public
    attr_reader :uri

    # Returns the relation registry used by the engine
    #
    # @example
    #   uri    = "postgres://localhost/test"
    #   engine = DataMapper::Engine::VeritasEngine.new(uri)
    #   engine.relations
    #
    # @return [Graph]
    #
    # @api public
    attr_reader :relations

    # @api public
    def self.register_as(name)
      Engine.engines[name] = self
    end

    # @api private
    def self.build(options)
      name = options[:engine]

      if name
        require "data_mapper/engine/#{name}"
        engines.fetch(name).new(options[:uri])
      else
        raise(
          MissingEngineError,
          "#{name.inspect} is not a correct engine identifier"
        )
      end
    end

    # @api private
    def self.engines
      @engines ||= {}
    end

    # Initializes an engine instance
    #
    # @param [String] uri
    #   the database connection URI
    #
    # @return [undefined]
    #
    # @api private
    def initialize(uri = nil)
      @uri       = Addressable::URI.parse(uri)
      @relations = Relation::Graph.new(self)
    end

    # Returns the relation node class used in the relation registry
    #
    # @example
    #   uri    = "postgres://localhost/test"
    #   engine = DataMapper::Engine::VeritasEngine.new(uri)
    #   engine.relation_node_class
    #
    # @return [Graph::Node]
    #
    # @api public
    def relation_node_class
      Relation::Graph::Node
    end

    # Returns the relation edge class used in the relation registry
    #
    # @example
    #   uri    = "postgres://localhost/test"
    #   engine = DataMapper::Engine::VeritasEngine.new(uri)
    #   engine.relation_edge_class
    #
    # @return [Graph::Edge]
    #
    # @api public
    def relation_edge_class
      Relation::Graph::Edge
    end

    # Builds a relation instance that will be wrapped in a relation node
    #
    # @example
    #   uri    = "postgres://localhost/test"
    #   engine = DataMapper::Engine::VeritasEngine.new(uri)
    #   engine.base_relation(:foo)
    #
    # @param [Symbol] name
    #   the base relation name
    #
    # @abstract
    #
    # @raise NotImplementedError
    #
    # @return [Object]
    #
    # @api public
    abstract_method :base_relation

    # Returns a gateway relation instance
    #
    # This is optional and by default it just returns the given relation back.
    # Currently it's only here for {VeritasEngine}. Most of the engines won't need
    # to override it.
    #
    # @example
    #   uri      = "postgres://localhost/test"
    #   engine   = DataMapper::Engine::VeritasEngine.new(uri)
    #   relation = Veritas::Relation::Base.new(:foo, [ [ :id, Integer ] ])
    #   engine.gateway_relation(relation)
    #
    # @param [Object] relation
    #   the relation to be wrapped in a gateway relation
    #
    # @return [Object]
    #   the relation that was passed in
    #
    # @api public
    def gateway_relation(relation)
      relation
    end

  end # class Engine

end # module DataMapper
