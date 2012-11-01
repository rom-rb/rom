module DataMapper
  class Relationship
    module Builder

      class BelongsTo
        include Builder

        # TODO: add specs
        def self.build(source, name, *args, &op)
          new(source, name, *args, &op).relationship
        end

        # TODO: add specs
        def initialize(source, name, *args, &op)
          target_model = Utils.extract_type(args)
          options      = Utils.extract_options(args).merge(:operation => op)

          @relationship = Relationship::ManyToOne.new(
            name, source.model, target_model, options
          )
        end
      end # class BelongsTo
    end # module Builder
  end # class Relationship
end # module DataMapper
