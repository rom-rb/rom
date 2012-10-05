module DataMapper
  class RelationRegistry
    class Edge
      class Builder

        class SingleHop < self

          def build
            source_relation = DataMapper[relationship.source_model].relation
            target_relation = DataMapper[relationship.target_model].relation

            source_node = Mapper.relation_registry.node_for(source_relation)
            target_node = Mapper.relation_registry.node_for(target_relation)

            # TODO raise a more descriptive error
            raise ArgumentError unless source_node && target_node

            edge_side = RelationRegistry::Edge::Side

            source = edge_side.new(source_node, relationship.source_key)
            target = edge_side.new(target_node, relationship.target_key)

            Mapper.relation_registry.add_edge(source, target, relationship)
          end
        end # class SingleHop
      end # class Builder
    end # class Edge
  end # class RelationRegistry
end # module DataMapper
