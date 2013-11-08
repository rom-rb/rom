# encoding: utf-8

module ROM
  class Mapper
    class Builder
      class Attribute

        class Simple < self

          def self.new(attribute, mappers)
            return super if self <= Simple
            klass = attribute.typed? ? Typed : self
            klass.new(attribute, mappers)
          end

          class Typed < self
            include Attribute::Typed

            private

            def type_transformer
              Ducktrap::Node::Primitive.new(type)
            end
          end
        end # class Simple
      end # class Attribute
    end # class Builder
  end # class Mapper
end # module ROM
