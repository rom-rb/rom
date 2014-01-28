# encoding: utf-8

module ROM
  class Mapper
    class Builder
      class Attribute

        class Embedded < self

          class Value < self
            private

            def transformer
              mappers[type].transformer
            end
          end # Value

          class Collection < Value
            private

            def transformer
              Ducktrap::Node::Map.new(super)
            end
          end # Collection

        end # Embeddded
      end # Attribute
    end # Builder
  end # Mapper
end # ROM
