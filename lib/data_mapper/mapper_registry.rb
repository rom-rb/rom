module DataMapper

  # MapperRegistry
  #
  class MapperRegistry

    # @api public
    def initialize(mappers = {})
      @_mappers = mappers
    end

    # @api public
    def [](model)
      @_mappers[model]
    end

    # @api public
    def <<(mapper)
      @_mappers[mapper.model] = mapper.new(gateway_for(mapper))
    end

  private

    # @api private
    def gateway_for(mapper)
      Veritas::Relation::Gateway.new(
        DataMapper.adapters[mapper.repository],
        DataMapper.relation_registry[mapper.relation_name])
    end

  end # class MapperRegistry
end # module DataMapper
