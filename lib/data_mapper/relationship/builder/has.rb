module DataMapper
  class Relationship
    module Builder

      class Has

        include Builder

        def self.build(source, cardinality, name, *args, &op)
          new(source, cardinality, name, *args, &op).relationship
        end

        def initialize(source, cardinality, name, *args, &op)
          options = Utils.extract_options(args)
          via     = options[:through]

          min, max = extract_min_max(cardinality, name)
          options.update(:min => min, :max => max)

          if max == 1 && via
            @relationship = source.relationships[via].inherit(name, op)
            return
          end

          options      = options.merge(:operation => op)
          target_model = Utils.extract_type(args)

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

          @relationship = options.type.new(options)
        end

        private

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
