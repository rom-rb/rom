module DataMapper
  module Relation
    class Aliases

      class Strategy

        include AbstractType
        include Adamantium

        # Initialize a new instance
        #
        # @param [AttributeIndex] attribute_index
        #   the attribute index used by this instance
        #
        # @param [#to_hash] join_definition
        #   the attributes used for joining two attribute indexes
        #
        # @return [undefined]
        #
        # @api private
        def initialize(attribute_index, join_definition)
          @attribute_index = attribute_index
          @join_definition = join_definition.to_hash
          @entries         = @attribute_index.entries
        end

        # Join two {AttributeIndex} instances
        #
        # @param [AttributeIndex] attribute_index
        #   the attribute index to join with the instance's own attribute index
        #
        # @return [AttributeIndex]
        #
        # @api private
        def join(attribute_index)
          new_index(joined_entries(attribute_index))
        end

        private

        attr_reader :join_definition
        attr_reader :entries

        def joined_entries(attribute_index)
          attribute_index.entries.dup
        end

        def join_key_entries(attribute_index)
          with_new_index_entries(attribute_index) { |key, name, new_entries|
            join_definition.each do |left_key, right_key|
              if name.field == right_key
                attribute        = @attribute_index.attribute(left_key)
                new_entries[key] = Attribute.build(attribute.field, name.prefix)
              end
            end
          }
        end

        def clashing_entries(attribute_index)
          with_new_index_entries(attribute_index) { |key, name, new_entries|
            if clashing?(name)
              new_entries[key] = Attribute.build(key.field, key.prefix, true)
            end
          }
        end

        def clashing?(name)
          @attribute_index.attribute?(name.field)
        end

        def with_new_index_entries(attribute_index)
          attribute_index.entries.each_with_object({}) { |(key, name), new_entries|
            yield(key, name, new_entries)
          }
        end

        def current_name(attribute_index, name)
          attribute_index.fetch(name)
        end

        def new_index(new_entries)
          @attribute_index.class.new(new_entries, self.class)
        end

      end # class Strategy

    end # class Aliases
  end # module Relation
end # module DataMapper
