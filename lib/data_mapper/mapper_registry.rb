module DataMapper

  class MapperRegistry

    class Identifier
      attr_reader :model
      attr_reader :relationships

      def initialize(model, relationships = [])
        @model         = model
        @relationships = Array(relationships)
        @hash          = @model.hash ^ @relationships.hash
      end

      attr_reader :hash

      def eql?(other)
        return false unless instance_of?(other.class)
        @model.eql?(other.model) && @relationships.eql?(other.relationships)
      end

      def ==(other)
        return false unless self.class <=> other.class
        @model == other.model && @relationships == other.relationships
      end
    end

    # @api public
    def initialize(mappers = {})
      @_mappers = mappers
    end

    def each
      return to_enum unless block_given?
      @_mappers.each { |identifier, mapper| yield(identifier, mapper) }

      self
    end

    def include?(model, relationships = [])
      @_mappers.key?(Identifier.new(model, relationships))
    end

    # @api public
    def [](model, relationships = [])
      @_mappers[Identifier.new(model, relationships)]
    end

    # @api public
    def register(mapper, relationships = [])
      @_mappers[Identifier.new(mapper.class.model, relationships)] = mapper
    end

    # @api public
    def <<(mapper, relationships = [])
      register(mapper, relationships)
    end
  end # class MapperRegistry
end # module DataMapper
