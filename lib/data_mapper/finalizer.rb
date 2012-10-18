module DataMapper

  class Finalizer
    attr_reader :mapper_registry
    attr_reader :connector_builder
    attr_reader :mapper_builder
    attr_reader :mappers

    def self.run
      new(Mapper.descendants.select { |mapper| mapper.model }).run
    end

    def initialize(mappers)
      @mappers           = mappers
      @mapper_registry   = Mapper.mapper_registry
      @connector_builder = RelationRegistry::Connector::Builder
      @mapper_builder    = Mapper::Builder

      @base_relation_mappers = @mappers.select { |mapper| mapper.respond_to?(:relation_name) }
    end

    def run
      finalize_base_relation_mappers
      finalize_attribute_mappers
      finalize_relationship_mappers

      self
    end

    private

    def finalize_base_relation_mappers
      @base_relation_mappers.each do |mapper|
        name     = mapper.relation.name
        relation = mapper.gateway_relation
        aliases  = mapper.aliases

        mapper.relations.new_node(name, relation, aliases)

        mapper.finalize
      end

      @base_relation_mappers.each do |mapper|
        mapper.relationships.each do |relationship|
          connector_builder.call(mapper_registry, mapper.relations, relationship)
        end
      end
    end

    def finalize_attribute_mappers
      mappers.each { |mapper| mapper.finalize_attributes }
    end

    def finalize_relationship_mappers
      @base_relation_mappers.each do |mapper|
        relations = mapper.relations

        relations.edges.each do |edge|
          connector           = relations.connectors[edge.name]
          source_mapper_class = mapper_registry[connector.source_model].class
          mapper              = mapper_builder.call(connector, source_mapper_class)

          next if mapper_registry[connector.source_model, connector.relationship]

          mapper_registry.register(mapper, connector.relationship)
        end
      end
    end
  end # class Finalizer
end # module DataMapper
