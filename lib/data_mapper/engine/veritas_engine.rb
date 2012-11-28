require 'veritas'
require 'veritas-do-adapter'

module DataMapper
  class Engine

    # Engine for Veritas
    class VeritasEngine < self

      # @see Engine#adapter
      #
      # @example
      #   uri    = "postgres://localhost/test"
      #   engine = DataMapper::Engine::VeritasEngine.new(uri)
      #   engine.adapter
      #
      # @return [Veritas::Adapter::DataObjects]
      #
      # @api public
      attr_reader :adapter

      # @see Engine#initialize
      #
      # @return [undefined]
      #
      # @api private
      def initialize(uri)
        super
        # TODO: add support for other adapters based on uri
        @adapter = Veritas::Adapter::DataObjects.new(uri)
      end

      # Returns the relation node class used in the relation registry
      #
      # @see Engine#relation_node_class
      #
      # @return [RelationRegistry::RelationNode::VeritasRelation]
      #
      # @api public
      def relation_node_class
        RelationRegistry::RelationNode::VeritasRelation
      end

      # Returns the relation edge class used in the relation registry
      #
      # @see Engine#relation_edge_class
      #
      # @example
      #   uri    = "postgres://localhost/test"
      #   engine = DataMapper::Engine::VeritasEngine.new(uri)
      #   engine.relation_edge_class
      #
      # @return [RelationRegistry::RelationEdge::VeritasEdge]
      #
      # @api public
      def relation_edge_class
        RelationRegistry::RelationEdge::VeritasEdge
      end

      # @see Engine#base_relation
      #
      # @param [Symbol] name
      #   the base relation name
      #
      # @param [Array<Array(Symbol, Class)>] header
      #   the base relation header
      #
      # @return [Veritas::Relation::Base]
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
      # @return [Veritas::Relation::Gateway]
      #
      # @api public
      def gateway_relation(relation)
        Veritas::Relation::Gateway.new(adapter, relation)
      end

    end # class VeritasEngine
  end # class Engine
end # module DataMapper
