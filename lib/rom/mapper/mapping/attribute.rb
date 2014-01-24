# encoding: utf-8

module ROM
  class Mapper
    class Mapping

      class Attribute

        include AbstractType
        include Concord::Public.new(:name, :type)
        include Adamantium::Flat

        abstract_method :builder

        def transformer(mappings)
          builder.call(self, mappings)
        end

        def typed?
          !type.equal?(Undefined)
        end

        class Simple < self
          private

          def builder
            Builder::Attribute::Simple
          end
        end # Simple

        class EmbeddedValue < self
          private

          def builder
            Builder::Attribute::Embedded::Value
          end
        end # EmbeddedValue

        class EmbeddedCollection < self
          private

          def builder
            Builder::Attribute::Embedded::Collection
          end
        end # EmbeddedCollection

      end # Attribute
    end # Mapping
  end # Mapper
end # ROM
