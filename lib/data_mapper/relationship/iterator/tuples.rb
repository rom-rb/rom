module DataMapper
  class Relationship
    module Iterator

      # Extracts child tuples from a flat (joined) relation into
      # tuples that can then be mapped using the child mapper.
      class Tuples

        def self.prepared(name, attributes, relation, &block)
          new(name, attributes, relation).each do |tuple|
            yield(tuple)
          end
        end

        def initialize(name, attributes, relation)
          @name       = name
          @raw_tuples = relation.to_a
          @parent_key = attributes.key
          @primitives = attributes.primitives

          @tuples       = {}
          @child_tuples = {}
          @index        = {}

          @raw_tuples.each_with_index { |tuple, index|
            @index[index] = [ key_tuple(tuple), tuple ]
          }

          initialize_tuples
        end

        def each(&block)
          unique_keys.each { |key| yield(@tuples[key])}
        end

        private

        def unique_keys
          @index.values.map(&:first).uniq
        end

        def initialize_tuples
          @index.each_value do |(key_tuple, tuple)|
            @tuples[key_tuple] = parent_tuple(key_tuple, tuple)
          end
        end

        def parent_tuple(parent_key_tuple, tuple)
          parent_base_tuple(tuple).merge(@name => child_tuples(parent_key_tuple))
        end

        def parent_base_tuple(tuple)
          @primitives.each_with_object({}) { |attribute, parent|
            field         = attribute.field
            parent[field] = tuple[field]
          }
        end

        def child_tuples(parent_key_tuple)
          @child_tuples.fetch(parent_key_tuple) {
            @child_tuples[parent_key_tuple] = tuples(parent_key_tuple)
          }
        end

        def tuples(parent_key_tuple)
          @raw_tuples.select { |tuple| parent_key_tuple == key_tuple(tuple) }
        end

        def key_tuple(tuple)
          @parent_key.map { |attribute| tuple[attribute.field] }
        end

      end # class Tuples

    end # module Iterator
  end # class Relationship
end # module DataMapper
