module DataMapper
  class Finalizer

    class BaseRelationMappersFinalizer < self

      # @api private
      def run
        finalize_mappers
        finalize_relationships
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
      def finalize_relationships
        mappers.each do |mapper|
          register_relationships(mapper)
        end
      end

      # @api private
      def register_base_relation(mapper)
        name     = mapper.relation_name
        relation = mapper.gateway_relation
        keys     = DependentRelationshipSet.new(mapper.model, mappers).target_keys
        aliases  = mapper.aliases.exclude(*keys)

        mapper.relations.new_node(name, relation, aliases)
      end

      # @api private
      def register_relationships(mapper)
        mapper.relationships.each do |relationship|
          edge_builder.call(mapper.relations, mapper_registry, relationship)
        end
      end
    end # class BaseRelationMapperFinalizer
  end # class Finalizer
end # module DataMapper
