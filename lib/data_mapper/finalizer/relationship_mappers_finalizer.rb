module DataMapper
  class Finalizer

    class RelationshipMappersFinalizer < self

      # @api private
      def run
        mapper_relations.each do |relations|
          relations.connectors.each_value do |connector|
            relationship = connector.relationship
            mapper_class = connector.source_mapper.class
            mapper       = mapper_builder.call(connector, mapper_class)

            mapper_registry.register(mapper, relationship)
          end
        end
      end

      private

      # @api private
      def mapper_relations
        base_relation_mappers.map(&:relations).uniq
      end

    end # class RelationshipMapperFinalizer

  end # class Finalizer
end # module DataMapper
