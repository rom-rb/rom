module DataMapper
  class Engine

    # Engine for Veritas
    class VeritasEngine < self
      attr_reader :adapter

      def initialize(uri)
        super
        @adapter = Veritas::Adapter::DataObjects.new(uri)
      end

      # @api private
      def relation_node_class
        RelationRegistry::RelationNode::VeritasRelation
      end

      # @api private
      def relation_edge_class
        RelationRegistry::RelationEdge
      end

      # @api private
      def base_relation(name, header)
        Veritas::Relation::Base.new(name, header)
      end

      # @api private
      def gateway_relation(relation)
        Veritas::Relation::Gateway.new(adapter, relation)
      end

    end # class VeritasEngine
  end # class Engine
end # module DataMapper
