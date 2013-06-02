module Rom
  class Relationship
    module Builder

      # Builds M:1 relationship instances
      class BelongsTo

        # Build a {ManyToOne} relationship
        #
        # TODO: add specs
        #
        # @param [Mapper] source
        #   the mapper establishing this relationship
        #
        # @param [Symbol] name
        #   the relationship's name
        #
        # @param [::Class] target_model
        #   the class of the object this relationship is pointing to
        #
        # @param [Hash] options
        #   the relationship's options
        #
        # @option options [Symbol, Array<Symbol>] :source_key
        #   the source_model's attributes to join on
        #
        # @option options [Symbol, Array<Symbol>] :target_key
        #   the target_model's attributes to join on
        #
        # @return [ManyToOne]
        #
        # @api private
        def self.build(source, name, target_model, options = EMPTY_HASH, &op)
          Relationship::ManyToOne.new(
            name, source.model, target_model, options.merge(:operation => op)
          )
        end
      end # class BelongsTo
    end # module Builder
  end # class Relationship
end # module Rom
