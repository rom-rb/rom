module DataMapper

  # Creates mappers for join relations described by relationship definitions
  #
  class Finalizer

    # The mapper registry in use
    #
    # @return [Mapper::Registry]
    #
    # @api private
    attr_reader :mapper_registry

    # The connector builder in use
    #
    # @return [Relation::Graph::Connector::Builder]
    #
    # @api private
    attr_reader :connector_builder

    # The mapper builder in use
    #
    # @return [Relation::Mapper::Builder]
    #
    # @api private
    attr_reader :mapper_builder

    # The mappers to be finalized
    #
    # @return [Array<Mapper>]
    #
    # @api private
    attr_reader :mappers

    attr_reader :environment

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
    # @param [Array<Mapper>] mappers
    #   the mappers to be finalized
    #
    # @param [Relation::Graph::Connector::Builder] connector_builder
    #   the builder used to create edges, nodes and connectors for relationships
    #
    # @param [Relation::Mapper::Builder] mapper_builder
    #   the builder used to create mappers for relationships
    #
    # @return [undefined]
    #
    # @api private
    def initialize(environment, connector_builder = default_connector_builder, mapper_builder = default_mapper_builder)
      @environment       = environment
      @mappers           = environment.mappers
      @mapper_registry   = environment.registry
      @connector_builder = connector_builder
      @mapper_builder    = mapper_builder
    end

    # Perform finalization
    #
    # @return [self]
    #
    # @api private
    def run
      BaseRelationMappersFinalizer.call(environment, connector_builder, mapper_builder)
      RelationshipMappersFinalizer.call(environment, connector_builder, mapper_builder)
      self
    end

    private

    def default_connector_builder
      Relation::Graph::Connector::Builder
    end

    def default_mapper_builder
      Relation::Mapper::Builder
    end

  end # class Finalizer
end # module DataMapper
