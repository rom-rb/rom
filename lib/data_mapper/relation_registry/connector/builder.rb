module DataMapper
  class RelationRegistry
    class Connector

      # Builds connectors and register relation nodes for a given relationship
      #
      class Builder
        attr_reader :mappers
        attr_reader :relations
        attr_reader :relationship

        attr_reader :connector
        attr_reader :node

        SEPARATOR = 'X'.freeze

        # @api public
        def self.call(mappers, relations, relationship)
          klass = relationship.via ? ViaConnector : Builder
          klass.new(mappers, relations, relationship)
        end

        # @api private
        def initialize(mappers, relations, relationship)
          @mappers, @relations, @relationship = mappers, relations, relationship
          initialize_connector
          freeze
        end

        # @api private
        def initialize_connector
          unless left_node && right_node
            raise ArgumentError, "Missing left and/or right nodes for #{relationship.name} left: #{left_node.inspect} right: #{right_node.inspect}"
          end

          @connector = Connector.new(name, build_edge, relationship)
          @node      = relations.build_node(name, @connector.relation)

          relations.add_connector(@connector)
          relations.add_node(@node)
        end

        # @api private
        def name
          @name ||= :"#{left_name}_#{SEPARATOR}_#{right_name}"
        end

        # @api private
        def left_name
          left_node.name
        end

        # @api private
        def right_name
          relationship.name
        end

        # @api private
        def left_node
          @left_node ||= relations.node_for(left_mapper.relation)
        end

        # @api private
        def right_node
          @right_node ||= relations.node_for(right_mapper.relation)
        end

        # @api private
        def left_mapper
          @left_mapper ||= mappers[relationship.source_model]
        end

        # @api private
        def right_mapper
          @right_mapper ||= mappers[relationship.target_model]
        end

        # @api private
        def build_edge
          edge = relations.edges.detect { |e| e.connects?(left_node) }

          unless edge
            edge = relations.build_edge(relationship.name, left_node, right_node)
            relations.add_edge(edge)
          end

          edge
        end

      end # class Builder

    end # class RelationConnector
  end # class RelationRegistry
end # module DataMapper
