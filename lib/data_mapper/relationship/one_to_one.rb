module DataMapper
  class Relationship

    class OneToOne < self

      # @see Options#default_target_key
      #
      def default_target_key
        [ self.class.foreign_key_name(source_model.name) ].freeze
      end

      attr_reader :via_relationship

      # Set foreign keys for joining from intermediary to target
      #
      # @return [self]
      #
      # @api private
      def finalize(mapper_registry)
        if through

          definition = ViaDefinition.new(self, mapper_registry)

          @via              = definition.via
          @via_model        = definition.via_model
          @via_relationship = definition.via_relationship

          self
        else
          super
        end
      end
    end # class OneToOne
  end # class Relationship
end # module DataMapper
