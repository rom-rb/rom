module DataMapper
  class Relationship
    module Builder

      class Has
        include Builder

        # TODO: add specs
        def self.build(source, cardinality, name, *args, &op)
          new(source, cardinality, name, *args, &op).relationship
        end

        # TODO: add specs
        def initialize(source, cardinality, name, *args, &op)
          options      = Utils.extract_options(args)
          target_model = Utils.extract_type(args)

          via      = options[:through]
          min, max = extract_min_max(cardinality, name)

          options.update(:min => min, :max => max, :operation => op)

          options_class =
            if max > 1
              if via
                Relationship::Options::ManyToMany
              else
                Relationship::Options::OneToMany
              end
            else
              Relationship::Options::OneToOne
            end

          options = options_class.new(name, source.model, target_model, options)

          options.validate

          @relationship = options.type.new(options)
        end

        private

        # TODO: refactor
        def extract_min_max(cardinality, name = nil)
          case cardinality
          when Integer  then [ cardinality,       cardinality      ]
          when Range    then [ cardinality.first, cardinality.last ]
          else
            message = "must be Integer or Range but was #{cardinality.class}"

            if name
              source  = "#{self}.has(#{cardinality}, #{name.inspect}, ...)"
              message = "#{source}: #{message}"
            end

            raise ArgumentError, message
          end
        end
      end # class BelongsTo
    end # module Builder
  end # class Relationship
end # module DataMapper
