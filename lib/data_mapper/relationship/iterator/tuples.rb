module DataMapper
  class Relationship
    module Iterator

      class Tuples

        def self.prepared(name, mapper)
          new(name, mapper).tuples
        end

        attr_reader :tuples

        def initialize(name, mapper)
          @name       = name
          @raw_tuples = mapper.relation.to_a
          attributes  = mapper.attributes
          @parent_key = attributes.key
          @primitives = attributes.primitives

          @tuples       = {}
          @child_tuples = {}

          initialize_tuples
        end

        private

        def initialize_tuples
          @raw_tuples.each do |tuple|
            parent_key_tuple = key_tuple(tuple)
            @tuples[parent_key_tuple] = parent_tuple(parent_key_tuple, tuple)
          end
        end

        def parent_tuple(parent_key_tuple, tuple)
          parent = parent_base_tuple(tuple)
          parent[@name] = child_tuples(parent_key_tuple)
          parent
        end

        def parent_base_tuple(tuple)
          @primitives.each_with_object({}) { |attribute, parent|
            parent[attribute.field] = tuple[attribute.field]
          }
        end

        def child_tuples(parent_key_tuple)
          @child_tuples.fetch(parent_key_tuple) {
            @raw_tuples.select { |tuple| parent_key_tuple == key_tuple(tuple) }
          }
        end

        def key_tuple(tuple)
          @parent_key.map { |attribute| tuple[attribute.field] }
        end

      end # class Tuples

    end # module Iterator
  end # class Relationship
end # module DataMapper
