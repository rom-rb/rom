module Rom
  class Mapper

    # Mapper registry
    #
    class Registry

      # Identifier used for mapper hash
      class Identifier
        include Equalizer.new(:model, :relationships)

        # The model mapped by the identified mapper
        #
        # @return [::Class] a domain model class
        #
        # @api private
        attr_reader :model

        # The relationships mapped by the identified mapper
        #
        # @return [Array<Relationship>]
        #
        # @api private
        attr_reader :relationships

        # Initialize a new frozen {Identifier} instance
        #
        # @param [::Class] model
        #   the identified mapper's domain model class
        #
        # @param [Relationship, Array<Relationship>] relationships
        #   the identified mapper's mapped relationships
        #
        # @return [undefined]
        #
        # @api private
        def initialize(model, relationships = [])
          @model         = model
          @relationships = Array(relationships)
          freeze
        end

      end # class Identifier

      include Enumerable
      include Equalizer.new(:mappers)

      attr_reader :mappers

      protected :mappers

      # Initializes an empty mapper registry
      #
      # @param [Hash] mappers
      #
      # @return [undefined]
      #
      # @api private
      def initialize(mappers = {})
        @mappers = mappers
      end

      # Iterate on mappers
      #
      # @yield [Identifier, Mapper]
      #
      # @return [self]
      #
      # @api private
      def each
        return to_enum unless block_given?
        @mappers.each { |identifier, mapper| yield(identifier, mapper) }
        self
      end

      # Returns a model => relation_name map
      #
      # @return [Hash]
      #
      # @api private
      def relation_map
        @mappers.values.each_with_object({}) { |mapper, hash|
          hash[mapper.model] = mapper.relation_name
        }
      end

      # Checks if the given model has a mapper
      #
      # @param [Class]
      # @param [Relationship]
      #
      # @return [Boolean]
      #
      # @api private
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
      # @api private
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
      # @api private
      def register(mapper, relationships = [])
        @mappers[Identifier.new(mapper.model, relationships)] = mapper
        self
      end

      # @see #register
      #
      # @api private
      def <<(mapper, relationships = [])
        register(mapper, relationships)
      end

    end # class Registry
  end # class Mapper
end # module Rom
