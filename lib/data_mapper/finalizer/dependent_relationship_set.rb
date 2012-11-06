module DataMapper
  class Finalizer

    # Object aggregating all dependent relationships for the given model
    #
    # @api private
    class DependentRelationshipSet
      include Enumerable

      # Initialize a new dependent relationship set instance
      #
      # @param [Class]
      # @param [MapperRegistry]
      #
      # @return [undefined]
      #
      # @api private
      def initialize(model, mappers)
        @model, @mappers = model, mappers
        initialize_relationships
      end

      # Iterate over dependent relationships
      #
      # @yield [Relationship]
      #
      # @api private
      def each(&block)
        return to_enum unless block_given?
        @relationships.each(&block)
        self
      end

      # Return all unique target keys from dependent relationships
      #
      # @return [Array<Symbol>]
      #
      # @api private
      def target_keys
        map(&:target_key).uniq
      end

      private

      # Initializes all dependent relationships from all mappers
      #
      # @return [undefined]
      #
      # @api private
      def initialize_relationships
        @relationships = @mappers.map { |mapper|
          mapper_relationships = mapper.relationships
          relationships        = mapper_relationships.for_target(@model)
          via_relationships    = mapper_relationships.find_dependent(relationships)

          relationships + via_relationships
        }
        @relationships.uniq!
        @relationships.flatten!
      end
    end

  end # class Finalizer
end # module DataMapper
