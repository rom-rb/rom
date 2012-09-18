module DataMapper
  class Mapper

    module RelationshipDsl

      # @api public
      def has_many(name, *args, &operation)
        source_model = model
        target_model = extract_model(args)
        options      = extract_options(args).merge(:operation => operation)

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
          options = extract_options(args)

          if source = options[:through]
            relationships.add_through(source, name, &operation)
          else
            source_model = model
            target_model = extract_model(args)

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
        target_model = extract_model(args)

        options = extract_options(args).merge(:operation => operation)
        options = Relationship::Options::ManyToOne.new(
          name, source_model, target_model, options
        )

        relationships.add(name, options)
      end

      private

      # @api private
      def extract_model(args)
        model = args.first
        return nil if model.is_a?(Hash)
        model
      end

      # @api private
      def extract_options(args)
        options = args.last
        options.respond_to?(:to_hash) ? options.to_hash.dup : {}
      end
    end # module RelationshipDsl

  end # class Mapper
end # module DataMapper
