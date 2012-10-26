module DataMapper

  class MapperRegistry

    class Identifier
      include Equalizer.new(:model, :relationships)

      attr_reader :model
      attr_reader :relationships

      def initialize(model, relationships = [])
        @model         = model
        @relationships = Array(relationships)
        freeze
      end
    end

    include Enumerable

    # @api public
    def initialize(mappers = {})
      @mappers = mappers
    end

    # @api public
    def each
      return to_enum unless block_given?
      @mappers.each { |identifier, mapper| yield(identifier, mapper) }

      self
    end

    # @api public
    def include?(model, relationships = [])
      @mappers.key?(Identifier.new(model, relationships))
    end

    # @api public
    def [](model, relationships = [])
      @mappers[Identifier.new(model, relationships)]
    end

    # @api public
    def register(mapper, relationships = [])
      @mappers[Identifier.new(mapper.class.model, relationships)] = mapper
    end

    # @api public
    def <<(mapper, relationships = [])
      register(mapper, relationships)
    end
  end # class MapperRegistry
end # module DataMapper
