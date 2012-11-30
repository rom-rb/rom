require 'active_record' # lol
require 'data_mapper/engine/arel_engine/gateway'

module DataMapper
  class Engine

    # Engine for Arel
    #
    class ArelEngine < self
      attr_reader :adapter
      attr_reader :arel_engines

      def initialize(uri)
        super

        # FIXME: parse uri here
        ActiveRecord::Base.establish_connection(
          :database => 'dm-mapper_test',
          :username => 'postgres',
          :adapter  => 'postgresql'
        )

        @adapter = ActiveRecord::Base.connection

        @arel_engines = {}
      end

      # @api private
      def relation_node_class
        RelationRegistry::RelationNode::ArelRelation
      end

      # @api private
      def relation_edge_class
        RelationRegistry::RelationEdge::ArelEdge
      end

      # @api private
      def base_relation(name, header)
        Arel::Table.new(name, arel_engine_for(name, header))
      end

      # @api private
      def gateway_relation(relation)
        Gateway.new(self, relation)
      end

      private

      # @api private
      def arel_engine_for(name, header)
        # TODO: this is temporary. we need to find out how to create a thin arel engine
        arel_engines.fetch(name) {
          Class.new(ActiveRecord::Base) { self.table_name = name }
        }
      end

    end # class VeritasEngine
  end # class Engine
end # module DataMapper
