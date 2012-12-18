module DataMapper
  module Relation
    class Aliases

      class Strategy

        include AbstractType

        def initialize(index)
          @index   = index
          @entries = @index.entries
        end

        def join(index, join_definition)
          new_index(joined_entries(index, join_definition.to_hash), self.class)
        end

        private

        attr_reader :entries

        abstract_method :joined_entries

        private :joined_entries

        def renamed_join_key_entries(join_definition)
          entries.each_with_object({}) { |(key, name), renamed|
            join_definition.each do |left_key, right_key|
              if name.field == left_key
                renamed[key] = aliased_field(right_key, name.prefix)
              end
            end
          }
        end

        def aliased_field(*args)
          DataMapper::Mapper::Attribute.aliased_field(*args)
        end

        def new_index(*args)
          @index.class.new(*args)
        end

        def clash?(index, name)
          index.field?(name.field)
        end

      end # class Strategy

    end # class Aliases
  end # module Relation
end # module DataMapper
