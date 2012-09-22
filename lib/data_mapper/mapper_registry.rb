module DataMapper

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
      @_mappers[mapper.class.model] = mapper
    end

  end # class MapperRegistry
end # module DataMapper
