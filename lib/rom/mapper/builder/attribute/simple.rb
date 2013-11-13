# encoding: utf-8

module ROM
  class Mapper
    class Builder
      class Attribute

        class Simple < self

          def self.new(attribute, mappers)
            return super if self < Simple
            klass = attribute.typed? ? Typed : Untyped
            klass.new(attribute, mappers)
          end

          class Untyped < self
            private

            def transformer
              Ducktrap::Node::Identity.instance
            end
          end # class Untyped

          class Typed < self
            private

            def transformer
              Ducktrap::Node::Primitive.new(type)
            end
          end # class Typed

        end # class Simple
      end # class Attribute
    end # class Builder
  end # class Mapper
end # module ROM
