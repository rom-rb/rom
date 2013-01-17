module DataMapper
  class Relationship
    module Iterator

      class Tuples

        def self.prepared(name, mapper, &block)
          new(name, mapper).each do |tuple|
            yield(tuple)
          end
        end

        def initialize(name, mapper)
          @name       = name
          @raw_tuples = mapper.relation.to_a
          attributes  = mapper.attributes
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
            parent[attribute.field] = tuple[attribute.field]
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
