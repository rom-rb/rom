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
            @right_node ||= relations.node_for(right_mapper.relation)
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
            relations.build_node(via_connector.name, via_connector.relation)
          end

          # @api private
          def add_via_node
            self.class.call(mappers, relations, via_relationship).node
          end

        end # class ViaConnector

      end # class Builder
    end # class Connector
  end # class RelationRegistry
end # module DataMapper
