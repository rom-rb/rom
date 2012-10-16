module DataMapper

  class Finalizer

    def self.run
      new(Mapper.descendants.select { |mapper| mapper.model }).run
    end

    def initialize(mappers)
      @mappers = mappers
    end

    def run
      finalize_base_relation_mappers
      finalize_attribute_mappers
      finalize_relation_registry
      finalize_relationship_mappers

      self
    end

    private

    def finalize_base_relation_mappers
      @mappers.each { |mapper| mapper.finalize }
    end

    def finalize_attribute_mappers
      @mappers.each { |mapper| mapper.finalize_attributes }
    end

    def finalize_relation_registry
      @mappers.each do |mapper|
        mapper.relationships.each do |relationship|
          RelationRegistry::RelationConnector::Builder.call(
            DataMapper.mapper_registry,
            DataMapper.relation_registry,
            relationship
          )
        end
      end
    end

    def finalize_relationship_mappers
      Mapper.relation_registry.edges.each do |connector|
        source_mapper_class = Mapper.mapper_registry[connector.source_model].class
        mapper              = Mapper::Builder.call(connector, source_mapper_class)

        next if Mapper.mapper_registry[connector.source_model, connector.relationship]

        Mapper.mapper_registry.register(mapper, connector.relationship)
      end
    end
  end # class Finalizer
end # module DataMapper
