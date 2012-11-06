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
          keys     = target_keys_for(model)
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

      # @api private
      def target_keys_for(model)
        relationships_for_target(model).map(&:target_key).uniq
      end

      # @api private
      def relationships_for_target(model)
        target_relationships = mappers.map { |mapper|
          mapper_relationships = mapper.relationships
          relationships        = mapper_relationships.select { |relationship| relationship.target_model.equal?(model) }
          names                = relationships.map(&:name)
          via_relationships    = mapper_relationships.select { |relationship| names.include?(relationship.via) }

          relationships + via_relationships
        }
        target_relationships.flatten!
      end

    end # class BaseRelationMapperFinalizer

  end # class Finalizer
end # module DataMapper
