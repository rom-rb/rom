module DataMapper

  # Creates mappers for join relations described by relationship definitions
  #
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

    # @api private
    attr_reader :base_relation_mappers

    # Perform finalization
    #
    # @param *args
    #   the same parameters that {#initialize} accepts
    #
    # @return [Finalizer]
    #
    # @api private
    def self.call(*args)
      new(*args).run
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
    def initialize(mappers = Mapper::Relation.descendants, edge_builder = RelationRegistry::Builder, mapper_builder = Mapper::Builder)
      @mappers         = mappers
      @mapper_registry = Mapper.mapper_registry
      @edge_builder    = edge_builder
      @mapper_builder  = mapper_builder

      @base_relation_mappers = mappers.select { |mapper| mapper.respond_to?(:relation_name) }
    end

    # Perform finalization
    #
    # @return [self]
    #
    # @api private
    def run
      BaseRelationMappersFinalizer.call(mappers, edge_builder, mapper_builder)
      RelationshipMappersFinalizer.call(mappers, edge_builder, mapper_builder)
      self
    end

  end # class Finalizer
end # module DataMapper
