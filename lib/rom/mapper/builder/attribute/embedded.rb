# encoding: utf-8

module ROM
  class Mapper
    class Builder
      class Attribute

        class Embedded < self

          class Value < self
            private

            def type_transformer
              mappers[type].transformer
            end
          end # class Value

          class Collection < Value
            private

            def type_transformer
              Ducktrap::Node::Map.new(super)
            end
          end
        end # class Collection
      end # class Attribute
    end # class Builder
  end # class Mapper
end # module ROM
