module DataMapper
  class Mapper

    module RelationshipDsl

      # @api public
      def has_many(name, *args, &operation)
        model   = extract_model(args)
        options = extract_options(args)

        options[:source_model] = self.model
        options[:target_model] = model ? model : options.delete(:model)

        type = options[:through] ? Relationship::ManyToMany : Relationship::OneToMany

        relationships.add(name, options.merge(
          :type      => type,
          :operation => operation
        ))
      end

      # @api public
      def has(cardinality, name, *args, &operation)
        if cardinality == 1
          model   = extract_model(args)
          options = extract_options(args)
          source  = options[:through]

          if source
            relationships.add_through(source, name, &operation)
          else
            options[:source_model] = self.model
            options[:target_model] = model ? model : options.delete(:model)

            relationships.add(name, options.merge(
              :type => Relationship::OneToOne,
              :operation => operation
            ))
          end
        else
          raise "Relationship not supported"
        end
      end

      # @api public
      def belongs_to(name, *args, &operation)
        model   = extract_model(args)
        options = extract_options(args)

        options[:source_model] = self.model
        options[:target_model] = model ? model : options.delete(:model)

        relationships.add(name, options.merge(
          :type      => Relationship::ManyToOne,
          :operation => operation
        ))
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
