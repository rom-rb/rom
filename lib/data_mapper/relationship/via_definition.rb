module DataMapper
  class Relationship

    class ViaDefinition

      # Create a new instance for a given M:N relationship
      #
      # @param [Relationship::ManyToMany] relationship
      #   the M:N relationship used to define via info
      #
      # @param [MapperRegistry] mapper_registry
      #   the registry of available mappers
      #
      # @return [Explicit] if relationship.via is a Hash
      # @return [Inferred] if relationship.via is nil or a Symbol
      #
      # @api private
      def self.new(relationship, mapper_registry)
        return super if self < ViaDefinition
        klass = relationship.via.is_a?(Hash) ? Explicit : Inferred
        klass.new(relationship, mapper_registry)
      end

      include AbstractType

      attr_reader :via
      attr_reader :via_model
      attr_reader :via_source_key
      attr_reader :via_target_key

      private

      def initialize(relationship, mapper_registry)
        @relationship    = relationship
        @via             = @relationship.via
        @mapper_registry = mapper_registry

        initialize_join_keys
      end

      class Explicit < self

        private

        def initialize_join_keys
          @via_source_key = Array(via.keys)
          @via_target_key = Array(via.values)
        end
      end # class Explicit

      class Inferred < self

        def via_relationship
          via_relationships[via] || via_relationships[name]
        end

        private

        def initialize_join_keys
          @via ||= inferred_via_name

          @via_model      = intermediary_model
          @via_source_key = via_relationship.source_key
          @via_target_key = via_relationship.target_key
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
          Inflector.underscore(target_model.name).to_sym
        end
      end # class Inferred
    end # class ViaDefinition
  end # class Relationship
end # module DataMapper
