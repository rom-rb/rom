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
        relation_registries.each do |relation_registry|
          register_relationship_mappers(relation_registry)
        end
      end

      # @api private
      def register_relationship_mappers(relation_registry)
        relation_registry.connectors.each_value do |connector|
          mapper = mapper_builder.call(connector, environment)
          mapper_registry.register(mapper, connector.relationship)
        end
      end

      # @api private
      def finalize_attribute_mappers
        mappers.each { |mapper| mapper.finalize_attributes(mapper_registry) }
      end

      # @api private
      def relation_registries
        mappers.map(&:relations).uniq
      end

    end # class RelationshipMapperFinalizer

  end # class Finalizer
end # module DataMapper
