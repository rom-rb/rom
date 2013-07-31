module ROM
  class Mapper

    class AttributeSet
      include Enumerable, Concord.new(:header, :attributes), Adamantium

      def self.coerce(header, mapping = {})
        attributes = header.each_with_object({}) { |field, object|
          attribute = Attribute.coerce(field, mapping[field.name])
          object[attribute.name] = attribute
        }
        new(header, attributes)
      end

      # @api private
      def mapping
        each_with_object({}) { |attribute, hash|
          hash[attribute.tuple_key] = attribute.name
        }
      end
      memoize :mapping

      def keys
        # FIXME: find a way to simplify this
        header.keys.flat_map { |key_header|
          key_header.flat_map { |key|
            attributes.values.select { |attribute|
              attribute.tuple_key == key.name
            }
          }
        }
      end

      def each(&block)
        return to_enum unless block_given?
        attributes.each_value(&block)
        self
      end

    end # AttributeSet

  end # Mapper
end # ROM
