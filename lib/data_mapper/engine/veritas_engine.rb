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
      #
      # TODO: add specs
      def initialize(uri)
        super
        # TODO: add support for other adapters based on uri
        @adapter = Veritas::Adapter::DataObjects.new(uri)
      end

      # @see Engine#relation_node_class
      #
      # @return [RelationRegistry::RelationNode::VeritasRelation]
      #
      # @api public
      #
      # TODO: add specs
      def relation_node_class
        RelationRegistry::RelationNode::VeritasRelation
      end

      # @see Engine#relation_edge_class
      #
      # @return [RelationRegistry::RelationEdge]
      #
      # @api public
      #
      # TODO: add specs
      def relation_edge_class
        RelationRegistry::RelationEdge
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
      #
      # TODO: add specs
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
      #
      # TODO: add specs
      def gateway_relation(relation)
        Veritas::Relation::Gateway.new(adapter, relation)
      end

    end # class VeritasEngine
  end # class Engine
end # module DataMapper
