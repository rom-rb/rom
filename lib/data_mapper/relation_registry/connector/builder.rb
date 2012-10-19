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

        # @api public
        def self.call(*args)
          new(*args)
        end

        # @api private
        def initialize(mappers, relations, relationship)
          @mappers, @relations, @relationship = mappers, relations, relationship
          initialize_connector
          freeze
        end

        private

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
          @name ||= :"#{left_node.name}_X_#{relationship.name}"
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
        def via_mapper
          @via_mapper ||= mappers[via_relationship.target_model]
        end

        # @api private
        def via?
          relationship.via
        end

        # @api private
        def via_relationship
          @via_relationship ||= left_mapper.relationships[relationship.via]
        end

        # @api private
        def via_name
          @via_name ||= via_relationship.name
        end

        # @api private
        def via_connector_name
          @via_connector_name ||= :"#{left_mapper.class.relation_name}_X_#{via_name}"
        end

        # @api private
        def left_node
          @left_node ||= (via? ? via_node : relations.node_for(left_mapper.relation))
        end

        # @api private
        def right_node
          @right_node ||=
            begin
              right_node = relations.node_for(right_mapper.relation)

              if via?
                right_node.aliased_for(via_relationship)
              else
                right_node
              end
            end
        end

        # @api private
        def via_connector
          relations.connectors[via_connector_name]
        end

        # @api private
        def via_node
          @via_node ||=
            begin
              if via_connector
                relations.build_node(
                  via_connector.name,
                  via_connector.aliased_for(relationship).relation
                )
              else
                build_via_node
              end
            end
        end

        # @api private
        def build_via_node
          self.class.call(mappers, relations, via_relationship).node.aliased_for(relationship)
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
