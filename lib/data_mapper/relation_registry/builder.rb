module DataMapper
  class RelationRegistry

    # Builds relation nodes for relationships
    #
    class Builder
      attr_reader :relations
      attr_reader :mappers
      attr_reader :relationship

      attr_reader :connector

      # @api private
      def self.call(relations, mappers, relationship)
        klass = relationship.via ? ViaBuilder : BaseBuilder
        klass.new(relations, mappers, relationship)
      end

      # @api private
      def initialize(relations, mappers, relationship)
        @relations, @mappers, @relationship = relations, mappers, relationship
        initialize_nodes

        edge     = build_edge
        relation = build_relation(edge)
        node     = build_node(name, relation)

        @connector = RelationRegistry::Connector.new(name, node, relationship, relations)
        relations.add_connector(@connector)
      end

      # @api private
      def left_name
        mappers[relationship.source_model].class.relation_name
      end

      # @api private
      def right_name
        mappers[relationship.target_model].class.relation_name
      end

      # @api private
      def left_node
        relations[left_name]
      end

      # @api private
      def right_node
        relations[right_name]
      end

      private

      # @api private
      def initialize_nodes
        # no-op
      end

      # @api private
      def build_relation(edge, relationship = relationship)
        relation = edge.relation
        relation = relation.instance_eval(&relationship.operation) if relationship.operation
        relation
      end

      # @api private
      def build_node(name, relation)
        unless relations[name]
          node = relations.build_node(name, relation)
          relations.add_node(node)
        else
          node = relations[name]
        end
        node
      end

      # @api private
      def build_edge(name = name, left = left_node, right = right_node)
        edge = relations.edge_for(left, right)

        unless edge
          edge = relations.build_edge(name, left, right)
          relations.add_edge(edge)
        end

        edge
      end

    end # class Builder

  end # class RelationRegistry
end # module DataMapper
