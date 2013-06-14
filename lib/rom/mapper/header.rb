module ROM
  class Mapper
    Attribute = Struct.new(:field, :name)

    class AttributeSet
      include Enumerable, Concord.new(:attributes)

      def self.coerce(header, mapping = {})
        merged_mapping = Hash[
          header.map { |attribute| [ attribute.name, attribute.name ] }
        ].merge(mapping)

        attributes = merged_mapping.each_with_object({}) { |(field, name), object|
          object[name] = Attribute.new(field, name)
        }

        new(attributes)
      end

      def each(&block)
        return to_enum unless block_given?
        attributes.each_value(&block)
        self
      end

      def [](name)
        attributes[name]
      end

    end # AttributeSet

    class Header
      include Enumerable, Concord.new(:header, :attributes)

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
