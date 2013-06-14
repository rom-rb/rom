module ROM
  class Mapper

    class AttributeSet
      include Enumerable, Concord.new(:attributes), Adamantium

      def self.coerce(header, mapping = {})
        attributes = header.each_with_object({}) { |field, object|
          attribute = Attribute.coerce(field, mapping[field.name])
          object[attribute.name] = attribute
        }
        new(attributes)
      end

      def each(&block)
        return to_enum unless block_given?
        attributes.each_value(&block)
        self
      end

    end # AttributeSet

  end # Mapper
end # ROM
