module DataMapper
  class Relationship
    module Builder

      class BelongsTo

        # TODO: add specs
        def self.build(source, name, target_model, options = {}, &op)
          options = options.merge(:operation => op)

          Relationship::ManyToOne.new(
            name, source.model, target_model, options
          )
        end
      end # class BelongsTo
    end # module Builder
  end # class Relationship
end # module DataMapper
