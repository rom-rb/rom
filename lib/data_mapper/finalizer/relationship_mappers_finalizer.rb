module DataMapper
  class Finalizer

    class RelationshipMappersFinalizer < self

      # @api private
      def run
        finalize_relationship_mappers
        finalize_attribute_mappers
        self
      end

      private

      # @api private
      def finalize_relationship_mappers
        mapper_relations.each do |relations|
          relations.connectors.each_value do |connector|
            relationship = connector.relationship
            mapper_class = connector.source_mapper.class
            mapper       = mapper_builder.call(connector, mapper_class)

            mapper_registry.register(mapper, relationship)
          end
        end
      end

      # @api private
      def finalize_attribute_mappers
        mappers.each(&:finalize_attributes)
      end

      # @api private
      def mapper_relations
        base_relation_mappers.map(&:relations).uniq
      end

    end # class RelationshipMapperFinalizer

  end # class Finalizer
end # module DataMapper
