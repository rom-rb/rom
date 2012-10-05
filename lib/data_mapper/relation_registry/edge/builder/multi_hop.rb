module DataMapper
  class RelationRegistry
    class Edge
      class Builder

        class MultiHop < self

          def build
            name = relationship.name

            via          = relationship.via
            source_model = relationship.source_model
            intermediary = DataMapper[source_model].class.relationships[via]

            source_relation = DataMapper[intermediary.target_model].relation
            target_relation = DataMapper[relationship.target_model].relation

            source_node = Mapper.relation_registry.node_for(source_relation)
            target_node = Mapper.relation_registry.node_for(target_relation)

            # TODO raise a more descriptive error
            raise ArgumentError unless source_node && target_node

            edge_side = RelationRegistry::Edge::Side

            source_key = [ Inflector.foreign_key(relationship.target_model.name).to_sym ]
            target_key = [ :id ]

            source = edge_side.new(source_node, source_key)
            target = edge_side.new(target_node, target_key)

            intermediary_node =
              Mapper.relation_registry.add_edge(source, target, intermediary)

            # -------------------------------------------------------------------------

            source_relation = DataMapper[intermediary.source_model].relation
            target_relation = intermediary_node.relation

            source_node = Mapper.relation_registry.node_for(source_relation)
            target_node = intermediary_node

            # TODO raise a more descriptive error
            raise ArgumentError unless source_node && target_node

            edge_side = RelationRegistry::Edge::Side

            source_key = intermediary.source_key
            target_key = intermediary_node.aliased(intermediary.target_key)

            source = edge_side.new(source_node, source_key)
            target = edge_side.new(target_node, target_key)

            Mapper.relation_registry.add_edge(source, target, relationship)
          end
        end # class MultiHop
      end # class Builder
    end # class Edge
  end # class RelationRegistry
end # module DataMapper
