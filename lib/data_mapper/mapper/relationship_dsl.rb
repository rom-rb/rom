module DataMapper
  class Mapper

    module RelationshipDsl

      # @api public
      def has_many(name, *args, &operation)
        source_model = model
        target_model = Utils.extract_type(args)
        options      = Utils.extract_options(args).merge(:operation => operation)

        options_class = if options[:through]
            Relationship::Options::ManyToMany
          else
            Relationship::Options::OneToMany
          end

        options = options_class.new(name, source_model, target_model, options)

        relationships.add(name, options)
      end

      # @api public
      def has(cardinality, name, *args, &operation)
        if cardinality == 1
          options = Utils.extract_options(args)

          if source = options[:through]
            relationships.add_through(source, name, &operation)
          else
            source_model = model
            target_model = Utils.extract_type(args)

            options = options.merge(:operation => operation)
            options = Relationship::Options::OneToOne.new(
              name, source_model, target_model, options
            )

            relationships.add(name, options)
          end
        else
          raise "Relationship not supported"
        end
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
    end # module RelationshipDsl

  end # class Mapper
end # module DataMapper
