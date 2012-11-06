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
          model = mapper.model

          next if mapper_registry[model]

          name     = mapper.relation_name
          relation = mapper.gateway_relation
          keys     = DependentRelationshipSet.new(model, mappers).target_keys
          aliases  = mapper.aliases.exclude(*keys)

          mapper.relations.new_node(name, relation, aliases)

          mapper.finalize
        end
      end

      # @api private
      def finalize_relationships
        mappers.each do |mapper|
          mapper.relationships.each do |relationship|
            edge_builder.call(mapper.relations, mapper_registry, relationship)
          end
        end
      end

    end # class BaseRelationMapperFinalizer

  end # class Finalizer
end # module DataMapper
