module ROM
  class Mapper
    Attribute = Struct.new(:field, :name)

    class Header
      include Enumerable, Concord.new(:header, :mapping)

      def self.coerce(attributes, options = {})
        header  = Axiom::Relation::Header.coerce(attributes)

        # FIXME: hide this complexity behind an attribute set object
        mapping = Hash[header.map { |attribute| [ attribute.name, attribute.name ] }]
        mapping.update(options.fetch(:map, {}))

        attributes = mapping.each_with_object({}) { |(field, name), object|
          object[field] = Attribute.new(field, name)
        }

        new(header, attributes)
      end

      def each(&block)
        return to_enum unless block_given?

        header.each do |attribute|
          yield(mapping[attribute.name])
        end

        self
      end

    end # Header

  end # Mapper
end # ROM
