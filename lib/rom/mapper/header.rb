module ROM
  class Mapper
    class Attribute < Struct.new(:name, :field)
      include Adamantium, Equalizer.new(:name, :field)

      def self.coerce(field, mapping = nil)
        new(mapping || field.name, field)
      end

      def tuple_key
        field.name
      end

    end

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

    class Header
      include Enumerable, Concord.new(:header, :attributes), Adamantium

      def self.coerce(attributes, options = {})
        header     = Axiom::Relation::Header.coerce(attributes)
        attributes = AttributeSet.coerce(header, options.fetch(:map, {}))
        new(header, attributes)
      end

      def each(&block)
        return to_enum unless block_given?
        attributes.each(&block)
        self
      end

    end # Header

  end # Mapper
end # ROM
