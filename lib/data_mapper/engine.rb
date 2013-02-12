require 'veritas'
require 'veritas-do-adapter'

module DataMapper

  # Abstract class for DataMapper engines
  #
  # @abstract
  class Engine

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

    # Returns the veritas database adapter
    #
    # @example
    #   uri    = "postgres://localhost/test"
    #   engine = DataMapper::Engine::Veritas::Engine.new(uri)
    #   engine.connection
    #
    # @return [::Veritas::Adapter::DataObjects]
    #
    # @api public
    attr_reader :adapter

    # Initializes an engine instance
    #
    # @param [String] uri
    #   the database connection URI
    #
    # @return [undefined]
    #
    # @api private
    def initialize(uri)
      @uri       = Addressable::URI.parse(uri)
      @relations = Relation::Graph.new(self)
      @adapter   = Veritas::Adapter::DataObjects.new(uri)
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

    # @see Engine#base_relation
    #
    # @param [Symbol] name
    #   the base relation name
    #
    # @param [Array<Array(Symbol, Class)>] header
    #   the base relation header
    #
    # @return [::Veritas::Relation::Base]
    #
    # @api public
    def base_relation(name, header)
      Veritas::Relation::Base.new(name, header)
    end

    # @see Engine#gateway_relation
    #
    # @param [Veritas::Relation] relation
    #   the relation to be wrapped in a gateway relation
    #
    # @return [::Veritas::Relation::Gateway]
    #
    # @api public
    def gateway_relation(relation)
      Veritas::Relation::Gateway.new(adapter, relation)
    end

  end # class Engine
end # module DataMapper
