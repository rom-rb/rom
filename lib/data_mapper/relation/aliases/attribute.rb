module DataMapper
  module Relation
    class Aliases

      class Attribute < Struct.new(:field, :prefix, :aliased)

        CACHE = {}

        def self.build(field, prefix, aliased = false)
          key = "#{field}-#{prefix}-#{aliased.inspect}"
          CACHE.fetch(key) {
            CACHE[key] = Attribute.new(field, prefix, aliased)
          }
        end

        attr_reader :name

        private :field=, :prefix=, :aliased=

        def initialize(field, prefix, aliased)
          super
          @name = aliased ? :"#{prefix}_#{field}" : field.to_sym
        end

      end # struct Attribute

    end # class Aliases
  end # module Relation
end # module DataMapper
