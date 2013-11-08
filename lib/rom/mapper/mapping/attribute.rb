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
            Mapper::Builder::Attribute::Simple
          end
        end

        class EmbeddedValue < self
          private

          def builder
            Mapper::Builder::Attribute::Embedded::Value
          end
        end

        class EmbeddedCollection < self
          private

          def builder
            Mapper::Builder::Attribute::Embedded::Collection
          end
        end
      end # class Attribute
    end # class Mapping
  end # class Mapper
end # module ROM
