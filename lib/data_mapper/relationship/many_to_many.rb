module DataMapper
  class Relationship

    # Represent a M:N relationship
    class ManyToMany < self

      include CollectionBehavior

      attr_reader :via_relationship

      # Set foreign keys for joining from intermediary to target
      #
      # @return [self]
      #
      # @api private
      def finalize(mapper_registry)
        definition = ViaDefinition.new(self, mapper_registry)

        @via              = definition.via
        @via_model        = definition.via_model
        @via_relationship = definition.via_relationship

        self
      end
    end # class ManyToMany
  end # class Relationship
end # module DataMapper
