module DataMapper

  # Creates mappers for join relations described by relationship definitions
  #
  # TODO: split this giant into smaller objects and add proper unit specs
  class Finalizer

    # The mapper registry in use
    #
    # @return [MapperRegistry]
    #
    # @api private
    attr_reader :mapper_registry

    # The edge builder in use
    #
    # @return [RelationRegistry::Builder]
    #
    # @api private
    attr_reader :edge_builder

    # The mapper builder in use
    #
    # @return [Mapper::Builder]
    #
    # @api private
    attr_reader :mapper_builder

    # The mappers to be finalized
    #
    # @return [Enumerable<Mapper>]
    #
    # @api private
    attr_reader :mappers

    # Perform finalization
    #
    # @example
    #   DataMapper::Finalizer.run
    #
    # @return [self]
    #
    # @api public
    def self.run
      new(Mapper.descendants.select { |mapper| mapper.model }).run
    end

    # Initialize a new finalizer instance
    #
    # @param [Enumerable<Mapper>] mappers
    #   the mappers to be finalized
    #
    # @param [RelationRegistry::Builder] edge_builder
    #   the builder used to create edges for relationships
    #
    # @param [Mapper::Builder] mapper_builder
    #   the builder used to create mappers for relationships
    #
    # @return [undefined]
    #
    # @api private
    def initialize(mappers, edge_builder = RelationRegistry::Builder, mapper_builder = Mapper::Builder)
      @mappers         = mappers
      @mapper_registry = Mapper.mapper_registry
      @edge_builder    = edge_builder
      @mapper_builder  = mapper_builder

      @base_relation_mappers = @mappers.select { |mapper| mapper.respond_to?(:relation_name) }
    end

    # Perform finalization
    #
    # @return [self]
    #
    # @api private
    def run
      finalize_base_relation_mappers
      finalize_attribute_mappers
      finalize_relationship_mappers

      self
    end

    private

    # @api private
    def target_keys_for(model)
      relationships_for_target(model).map(&:target_key).uniq
    end

    # @api private
    def relationships_for_target(model)
      @base_relation_mappers.map { |mapper|
        relationships     = mapper.relationships.select { |relationship| relationship.target_model.equal?(model) }
        names             = relationships.map(&:name)
        via_relationships = mapper.relationships.select { |relationship| names.include?(relationship.via) }

        relationships + via_relationships
      }.flatten
    end

    # @api private
    def finalize_base_relation_mappers
      @base_relation_mappers.each do |mapper|
        model = mapper.model

        next if mapper_registry[model]

        name     = mapper.relation.name
        relation = mapper.gateway_relation
        keys     = target_keys_for(model)
        aliases  = mapper.aliases.exclude(*keys)

        mapper.relations.new_node(name, relation, aliases)

        mapper.finalize
      end

      @base_relation_mappers.each do |mapper|
        mapper.relationships.each do |relationship|
          edge_builder.call(mapper.relations, mapper_registry, relationship)
        end
      end
    end

    # @api private
    def finalize_attribute_mappers
      mappers.each(&:finalize_attributes)
    end

    # @api private
    def finalize_relationship_mappers
      @base_relation_mappers.map(&:relations).uniq.each do |relations|
        relations.connectors.each_value do |connector|
          model        = connector.source_model
          relationship = connector.relationship
          mapper_class = mapper_registry[model].class
          mapper       = mapper_builder.call(connector, mapper_class)

          mapper_registry.register(mapper, relationship)
        end
      end

      @base_relation_mappers.each do |mapper|
        mapper.relations.freeze
      end
    end

  end # class Finalizer
end # module DataMapper
