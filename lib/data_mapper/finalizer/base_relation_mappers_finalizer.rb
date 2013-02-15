module DataMapper
  class Finalizer

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
          relation = register_base_relation(mapper)
          finalize_mapper(mapper, relation)
        end
      end

      # @api private
      def register_base_relation(mapper)
        name       = mapper.relation_name
        repository = environment.repository(mapper.repository)
        repository.register(name, mapper.attributes.header)
        relation = repository.get(name)
        header   = Relation::Graph::Node.header(name, mapper.attributes.fields)

        relation_node = relations.build_node(name, relation, header)
        relations.add_node(relation_node)
        relation_node
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

      # Perform mapper finalization
      #
      # @api private
      def finalize_mapper(mapper, relation)
        mapper_registry << mapper.new(environment, relation)
        mapper.freeze
      end
    end # class BaseRelationMapperFinalizer
  end # class Finalizer
end # module DataMapper
