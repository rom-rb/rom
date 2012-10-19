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

        # @api public
        def self.call(*args)
          new(*args).connector
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
          left_node  = build_left_node
          right_node = build_right_node

          unless left_node && right_node
            raise ArgumentError, "Missing left and/or right nodes for #{relationship.name} left: #{left_node.inspect} right: #{right_node.inspect}"
          end

          @connector = Connector.new(build_edge(left_node, right_node), relationship)

          relations.add_connector(@connector)
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
        def via?
          relationship.via
        end

        # @api private
        def via_relationship
          @via_relationship ||= left_mapper.relationships[relationship.via]
        end

        # @api private
        def via_name
          @via_name ||= :"#{left_mapper.relation.name}_#{via_relationship.name}"
        end

        # @api private
        def via_relation
          @via_relation ||=
            if relations[via_name]
              relations[via_name]
            else
              self.class.call(mappers, relations, via_relationship).aliased_for(relationship)
            end.relation
        end

        # @api private
        def build_left_node
          if via?
            node = relations.build_node(via_name, via_relation)
            relations.add_node(node)
            node
          else
            relations.node_for(left_mapper.relation)
          end
        end

        # @api private
        def build_right_node
          if via?
            node = relations.node_for(right_mapper.relation).aliased_for(via_relationship)
            relations.add_node(node)
            node
          else
            relations.node_for(right_mapper.relation)
          end
        end

        # @api private
        def build_edge(left, right)
          edge = relations.edges.detect { |e| e.name == relationship.name }

          unless edge
            edge = relations.build_edge(relationship.name, left, right)
            relations.add_edge(edge)
          end

          edge
        end

      end # class Builder

    end # class RelationConnector
  end # class RelationRegistry
end # module DataMapper
