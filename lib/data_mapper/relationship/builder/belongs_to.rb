module DataMapper
  class Relationship
    module Builder

      class BelongsTo
        include Builder

        # TODO: add specs
        def self.build(source, name, target_model, options = {}, &op)
          new(source, name, target_model, options, &op).relationship
        end

        # TODO: add specs
        def initialize(source, name, target_model, options = {}, &op)
          options = options.merge(:operation => op)

          @relationship = Relationship::ManyToOne.new(
            name, source.model, target_model, options
          )
        end
      end # class BelongsTo
    end # module Builder
  end # class Relationship
end # module DataMapper
