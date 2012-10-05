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
          RelationRegistry::Edge::Builder.build(relationship)
        end
      end
    end

    def finalize_relationship_mappers
      mapper_registry = Mapper.mapper_registry
      Mapper.relation_registry.nodes.each do |node|
        node.connectors.each do |name, connector|
          unless mapper_registry.include?(connector.source_model, name)
            mapper = Mapper::Builder.build(connector)
            mapper_registry.register(mapper, name)
          end
        end
      end
    end
  end # class Finalizer
end # module DataMapper
