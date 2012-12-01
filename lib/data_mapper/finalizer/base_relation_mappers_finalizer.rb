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
          register_base_relation(mapper)
          mapper.finalize
        end
      end

      # @api private
      def register_base_relation(mapper)
        name     = mapper.relation_name
        relation = mapper.gateway_relation
        aliases  = mapper.relations.aliases(name, mapper.attributes)

        mapper.relations.new_node(name, relation, aliases)
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
            connector_builder.call(mapper.relations, mapper_registry, relationship)
          end
        end
      end
    end # class BaseRelationMapperFinalizer
  end # class Finalizer
end # module DataMapper
