module DataMapper
  class RelationRegistry
    class Connector
      class Builder

        # Builds via connector
        #
        class ViaConnector < self

          # @api private
          def left_node
            @left_node ||= via_node
          end

          # @api private
          def right_node
            @right_node ||= relations.node_for(right_mapper.relation).aliased_for(via_relationship)
          end

          # @api private
          def via_mapper
            @via_mapper ||= mappers[via_relationship.target_model]
          end

          # @api private
          def via_relationship
            @via_relationship ||= left_mapper.relationships[relationship.via]
          end

          # @api private
          def via_connector_name
            @via_connector_name ||= :"#{left_mapper.class.relation_name}_#{SEPARATOR}_#{via_relationship.name}"
          end

          # @api private
          def via_connector
            relations.connectors[via_connector_name]
          end

          # @api private
          def via_node
            @via_node ||= via_connector ? build_via_node : add_via_node
          end

          # @api private
          def build_via_node
            relation = via_connector.aliased_for(relationship).relation
            name     = via_connector.name
            relations.build_node(name, relation)
          end

          # @api private
          def add_via_node
            self.class.call(mappers, relations, via_relationship).node.aliased_for(relationship)
          end

        end # class ViaConnector

      end # class Builder
    end # class Connector
  end # class RelationRegistry
end # module DataMapper
