module ROM
  class Relationship

    # Calculate join keys for the `via` relationship in M:N
    # relationships
    class ViaDefinition

      attr_reader :via
      attr_reader :via_model
      attr_reader :via_source_key
      attr_reader :via_target_key

      # Create a new instance for a given M:N relationship
      #
      # @param [Relationship::ManyToMany] relationship
      #   the M:N relationship used to define via info
      #
      # @param [Mapper::Registry] mapper_registry
      #   the registry of available mappers
      #
      # @return [Explicit] if relationship.via is a Hash
      # @return [Inferred] if relationship.via is nil or a Symbol
      #
      # @api private
      def initialize(relationship, mapper_registry)
        @relationship    = relationship
        @via             = @relationship.via
        @mapper_registry = mapper_registry
        @via_relationships = via_relationships

        initialize_join_keys
      end

      def via_relationship
        @via_relationships[via] || @via_relationships[name]
      end

      private

      def initialize_join_keys
        @via ||= inferred_via_name

        relationship    = via_relationship
        @via_model      = intermediary_model
        @via_source_key = relationship.source_key
        @via_target_key = relationship.target_key
      end

      def name
        @relationship.name
      end

      def through
        @relationship.through
      end

      def source_mapper
        @mapper_registry[source_model]
      end

      def via_mapper
        @mapper_registry[intermediary_model]
      end

      def source_model
        @relationship.source_model
      end

      def intermediary_model
        source_mapper.relationships[through].target_model
      end

      def target_model
        @relationship.target_model
      end

      def via_relationships
        via_mapper.relationships
      end

      def inferred_via_name
        Inflecto.underscore(target_model.name).to_sym
      end
    end # class ViaDefinition
  end # class Relationship
end # module ROM
