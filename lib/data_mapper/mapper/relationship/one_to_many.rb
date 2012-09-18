module DataMapper
  class Mapper

    # Attribute
    #
    # @api private
    class Relationship

      class OneToMany < Relationship

        module Iterator

          # @api public
          #
          # TODO: simplify this when veritas starts supporting tuple grouping
          def each
            return to_enum unless block_given?

            tuples     = @relation.to_a
            parent_key = @attributes.key
            name       = @attributes.detect { |attribute|
              attribute.kind_of?(Attribute::Collection)
            }.name

            parents = tuples.each_with_object({}) do |tuple, hash|
              key = parent_key.map { |attribute| tuple[attribute.field] }
              hash[key] = @attributes.primitives.each_with_object({}) { |attribute, parent|
                parent[attribute.field] = tuple[attribute.field]
              }
            end

            parents.each do |key, parent|
              parent[name] = tuples.map do |tuple|
                current_key = parent_key.map { |attribute| tuple[attribute.field] }
                if key == current_key
                  tuple
                end
              end.compact
            end

            parents.each_value { |parent| yield(load(parent)) }
            self
          end
        end

        # @api public
        def finalize
          super
          @mapper_class.send(:include, Iterator)
        end

        private

        def default_source_key
          :id
        end

        def default_target_key
          foreign_key_name
        end

        # @api private
        def relationship_builder
          Builder::OneToMany
        end

      end # class OneToMany

    end # class Relationship
  end # class Mapper
end # module DataMapper
