module DataMapper
  class Relationship
    class OneToMany < self

      module Iterator

        # Iterate over the loaded domain objects
        #
        # TODO: refactor this and add support for multi-include
        #
        # @see Mapper::Relation#each
        #
        # @example
        #
        #   DataMapper[Person].include(:tasks).each do |person|
        #     person.tasks.each do |task|
        #       puts task.name
        #     end
        #   end
        #
        # @yield [object] the loaded domain objects
        #
        # @yieldparam [Object] object
        #   the loaded domain object that is yielded
        #
        # @return [self]
        #
        # @api public
        def each
          return to_enum unless block_given?

          tuples     = relation.to_a
          parent_key = attributes.key

          name = attributes.detect { |attribute|
            attribute.kind_of?(Mapper::Attribute::EmbeddedCollection)
          }.name

          parents = map_parents(tuples, parent_key)

          # Mutate parents
          map_children(tuples, parent_key, parents, name)

          parents.each_value { |parent| yield(load(parent)) }

          self
        end

        private

        def map_parents(tuples, parent_key)
          tuples.each_with_object({}) do |tuple, parents|
            parents[key_tuple(parent_key, tuple)] = parent(tuple)
          end
        end

        # Mutates parents
        def map_children(tuples, parent_key, parents, name)
          parents.each do |parent_key_tuple, parent|
            parent[name] = children(tuples, parent_key, parent_key_tuple)
          end
        end

        def parent(tuple)
          attributes.primitives.each_with_object({}) { |attribute, parent|
            parent[attribute.field] = tuple[attribute.field]
          }
        end

        def children(tuples, parent_key, parent_key_tuple)
          tuples.select { |tuple|
            parent_key_tuple == key_tuple(parent_key, tuple)
          }
        end

        def key_tuple(key, tuple)
          key.map { |attribute| tuple[attribute.field] }
        end

      end # module Iterator

    end # class OneToMany
  end # class Relationship
end # module DataMapper
