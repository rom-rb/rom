module DataMapper
  class Relationship

    module Dsl

      # @api public
      def has(cardinality, name, *args, &operation)

        options = Utils.extract_options(args)
        source  = options[:through]

        min, max = extract_min_max(cardinality, name)
        options.update(:min => min, :max => max)

        if max == 1 && source
          return relationships.add_through(source, name, &operation)
        end

        options      = options.merge(:operation => operation)
        source_model = model
        target_model = Utils.extract_type(args)

        options_class =
          if max > 1
            if source
              Relationship::Options::ManyToMany
            else
              Relationship::Options::OneToMany
            end
          else
            Relationship::Options::OneToOne
          end

        options = options_class.new(name, source_model, target_model, options)

        relationships.add(name, options)
      end

      # @api public
      def belongs_to(name, *args, &operation)
        source_model = model
        target_model = Utils.extract_type(args)

        options = Utils.extract_options(args).merge(:operation => operation)
        options = Relationship::Options::ManyToOne.new(
          name, source_model, target_model, options
        )

        relationships.add(name, options)
      end

      def n
        Infinity
      end

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
    end # module Dsl
  end # class Relationship
end # module DataMapper
