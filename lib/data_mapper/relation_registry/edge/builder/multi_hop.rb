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

            intermediary_source_node = nil

            if intermediary.via

              source_relation_name = DataMapper[source_model].class.relation_name
              source_relation_node = Mapper.relation_registry.node(source_relation_name)

              source_node     = source_relation_node[relationship.via].target_side.node
              source_relation = source_node.relation

              # remember for later
              intermediary_source_node = source_node

              source_key = source_node.aliased(:id)
              target_key = [Inflector.foreign_key(intermediary.target_model.name).to_sym]

            else
              source_relation = DataMapper[intermediary.target_model].relation
              source_node = Mapper.relation_registry.node_for(source_relation)

              source_key = [ Inflector.foreign_key(relationship.target_model.name).to_sym ]
              target_key = [ :id ]
            end

            target_relation = DataMapper[relationship.target_model].relation
            target_node     = Mapper.relation_registry.node_for(target_relation)

            # TODO raise a more descriptive error
            raise ArgumentError unless source_node && target_node

            edge_side = RelationRegistry::Edge::Side

            source = edge_side.new(source_node, source_key)
            target = edge_side.new(target_node, target_key)

            intermediary_node = Mapper.relation_registry.add_edge(source, target)

            # -------------------------------------------------------------------------

            if intermediary.via
              source_relation = DataMapper[relationship.source_model].relation
              target_relation = intermediary_node.relation

              source_node = Mapper.relation_registry.node_for(source_relation)
              target_node = intermediary_node

              source_key = [ :id ]
              target_key = intermediary_source_node.aliased(Inflector.foreign_key(relationship.source_model.name).to_sym)

            else
              source_relation = DataMapper[intermediary.source_model].relation
              target_relation = intermediary_node.relation

              source_node = Mapper.relation_registry.node_for(source_relation)
              target_node = intermediary_node

              source_key = intermediary.source_key
              target_key = intermediary_node.aliased(intermediary.target_key)

            end

            # TODO raise a more descriptive error
            raise ArgumentError unless source_node && target_node

            edge_side = RelationRegistry::Edge::Side

            source = edge_side.new(source_node, source_key)
            target = edge_side.new(target_node, target_key)

            Mapper.relation_registry.add_edge(source, target, relationship)
          end
        end # class MultiHop
      end # class Builder
    end # class Edge
  end # class RelationRegistry
end # module DataMapper
