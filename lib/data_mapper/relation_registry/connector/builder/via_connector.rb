module DataMapper
  class RelationRegistry
    class Connector
      class Builder

        # Builds via connector
        #
        class ViaConnector < self

          # @api private
          def left_node
            @left_node ||= relations.node_for(left_mapper.relation).
              aliased_for(relationship).aliased_for(via_relationship)
          end

          # @api private
          def right_node
            @right_node ||= via_connector ? build_via_node : add_via_node
          end

          # @api private
          def right_name
            via_connector_name
          end

          # @api private
          def via_relationship
            @via_relationship ||= left_mapper.relationships[relationship.via].
              for_source(relationship.via, relationship.target_model)
          end

          # @api private
          def via_connector_name
            @via_connector_name ||= :"#{relationship.name}_#{SEPARATOR}_#{relationship.via}"
          end

          # @api private
          def via_connector
            relations.connectors[via_connector_name]
          end

          # @api private
          def build_via_node
            relation = via_connector.aliased_for(relationship).relation
            name     = via_connector.name
            relations.build_node(name, relation)
          end

          # @api private
          def add_via_node
            node = self.class.call(mappers, relations, via_relationship).node
            node.aliased_for(relationship)
          end

        end # class ViaConnector

      end # class Builder
    end # class Connector
  end # class RelationRegistry
end # module DataMapper
