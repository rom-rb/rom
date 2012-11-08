module DataMapper
  class Finalizer

    # Object aggregating all dependent relationships for the given model
    #
    # @api private
    class DependentRelationshipSet
      include Enumerable

      # All (frozen) target keys from dependent relationships
      #
      # @return [Set<Symbol>]
      #
      # @api private
      attr_reader :target_keys

      # Initialize a new dependent relationship set instance
      #
      # @param [Class]
      # @param [MapperRegistry]
      #
      # @return [undefined]
      #
      # @api private
      def initialize(model, mappers)
        @model         = model
        @mappers       = mappers
        @relationships = Set.new
        @target_keys   = Set.new

        initialize_relationships
        initialize_target_keys
      end

      # Iterate over dependent relationships
      #
      # @yield [Relationship]
      #
      # @return [self]
      #
      # @api private
      def each(&block)
        return to_enum unless block_given?
        @relationships.each(&block)
        self
      end

      private

      # Initializes all dependent relationships from all mappers
      #
      # @return [undefined]
      #
      # @api private
      def initialize_relationships
        @mappers.each do |mapper|
          @relationships.merge(mapper.relationships.find_dependent(@model))
        end

        @relationships.freeze
      end

      # Initialize all target keys from dependent relationships
      #
      # @return [undefined]
      #
      # @api private
      def initialize_target_keys
        @relationships.each do |relationship|
          @target_keys << relationship.target_key
        end

        @target_keys.freeze
      end
    end

  end # class Finalizer
end # module DataMapper
