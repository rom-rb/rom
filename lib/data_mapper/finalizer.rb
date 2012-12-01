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

    # The connector builder in use
    #
    # @return [RelationRegistry::Connector::Builder]
    #
    # @api private
    attr_reader :connector_builder

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
    # @param [RelationRegistry::Connector::Builder] connector_builder
    #   the builder used to create edges, nodes and connectors for relationships
    #
    # @param [Mapper::Builder] mapper_builder
    #   the builder used to create mappers for relationships
    #
    # @return [undefined]
    #
    # @api private
    def initialize(mappers = Mapper::Relation.descendants, connector_builder = RelationRegistry::Connector::Builder, mapper_builder = Mapper::Builder)
      @mappers           = mappers
      @mapper_registry   = Mapper.mapper_registry
      @connector_builder = connector_builder
      @mapper_builder    = mapper_builder
    end

    # Perform finalization
    #
    # @return [self]
    #
    # @api private
    def run
      BaseRelationMappersFinalizer.call(mappers, connector_builder, mapper_builder)
      RelationshipMappersFinalizer.call(mappers, connector_builder, mapper_builder)
      self
    end

  end # class Finalizer
end # module DataMapper
