module DataMapper
  class Mapper

    module RelationshipDsl

      # @api public
      def has_many(name, options = {}, &operation)
        type = options[:through] ? Relationship::ManyToMany : Relationship::OneToMany
        relationships.add(name, options.merge(:type => type, :operation => operation))
      end

      # @api public
      def has(cardinality, name, options = {}, &operation)
        if cardinality == 1
          source = options[:through]

          if source
            relationships.add_through(source, name, &operation)
          else
            relationships.add(name, options.merge(
              :type => Relationship::OneToOne, :operation => operation))
          end
        else
          raise "Relationship not supported"
        end
      end

      # @api public
      def belongs_to(model_name, options = {}, &operation)
        relationships.add(model_name, options.merge(
          :type => Relationship::ManyToOne, :operation => operation))
      end

    end # module RelationshipDsl

  end # class Mapper
end # module DataMapper
