module DataMapper

  # Mapper registry
  #
  class MapperRegistry

    # Identifier used for mapper hash
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

    # Initializes an empty mapper registry
    #
    # @param [Hash] mappers
    #
    # @return [undefined]
    #
    # @api public
    def initialize(mappers = {})
      @mappers = mappers
    end

    # Iterate on mappers
    #
    # @yield [Identifier, Mapper]
    #
    # @api public
    def each
      return to_enum unless block_given?
      @mappers.each { |identifier, mapper| yield(identifier, mapper) }
      self
    end

    # Returns a model => relation_name map
    #
    # @return [Hash]
    #
    # @api public
    def relation_map
      @mappers.values.each_with_object({}) { |mapper, h| h[mapper.model] = mapper.relation_name }
    end

    # Checks if the given model has a mapper
    #
    # @param [Class]
    # @param [Relationship]
    #
    # @return [Boolean]
    #
    # @api public
    def include?(model, relationships = [])
      @mappers.key?(Identifier.new(model, relationships))
    end

    # Accesses mapper instance by a given model or model and its relationship
    #
    # @param [Class]
    # @param [Relationship]
    #
    # @return [Mapper]
    #
    # @api public
    def [](model, relationships = [])
      @mappers[Identifier.new(model, relationships)]
    end

    # Registers a new mapper instance
    #
    # @param [Mapper]
    # @param [Relationship]
    #
    # @return [self]
    #
    # @api public
    def register(mapper, relationships = [])
      @mappers[Identifier.new(mapper.model, relationships)] = mapper
      self
    end

    # @see #register
    #
    # @api public
    def <<(mapper, relationships = [])
      register(mapper, relationships)
    end

  end # class MapperRegistry
end # module DataMapper
