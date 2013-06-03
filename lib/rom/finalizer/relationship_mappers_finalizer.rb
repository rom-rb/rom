module ROM
  class Finalizer

    # Finalizes mappers for all relationships
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
        relations.connectors.each_value do |connector|
          mapper = mapper_builder.call(connector, environment)
          mapper_registry.register(mapper, connector.relationship)
        end
      end

      # @api private
      def finalize_attribute_mappers
        mappers.each { |mapper| mapper.finalize_attributes(mapper_registry) }
      end

    end # class RelationshipMappersFinalizer
  end # class Finalizer
end # module ROM
