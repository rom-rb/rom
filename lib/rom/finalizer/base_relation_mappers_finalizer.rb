module Rom
  class Finalizer

    # Finalizes mappers for all base relations
    class BaseRelationMappersFinalizer < self

      # @api private
      def run
        finalize_mappers
        finalize_relationships
        finalize_edges
        self
      end

      private

      # @api private
      def finalize_mappers
        mappers.each do |mapper|
          finalize_mapper(mapper, register_base_relation(mapper))
        end
      end

      # @api private
      def register_base_relation(mapper)
        name   = mapper.relation_name
        header = Relation::Graph::Node.header(name, mapper.attributes.fields)

        registered_node(mapper, name, header)
      end

      # @api private
      def finalize_relationships
        mappers.each do |mapper|
          mapper.relationships.each do |relationship|
            relationship.finalize(mapper_registry)
          end
        end
      end

      # @api private
      def finalize_edges
        mappers.each do |mapper|
          mapper.relationships.each do |relationship|
            connector_builder.call(relations, mapper_registry, relationship)
          end
        end
      end

      private

      def registered_node(mapper, name, header)
        graph    = relations
        relation = registered_relation(name, mapper)

        node = graph.build_node(name, relation, header)
        graph.add_node(node)
        node
      end

      def registered_relation(name, mapper)
        repository = environment.repository(mapper.repository)
        repository.register(name, mapper.attributes.header)
        repository.get(name)
      end

      # Perform mapper finalization
      #
      # @api private
      def finalize_mapper(mapper, relation)
        mapper_registry << mapper.new(environment, relation)
        mapper.freeze
      end
    end # class BaseRelationMapperFinalizer
  end # class Finalizer
end # module Rom
