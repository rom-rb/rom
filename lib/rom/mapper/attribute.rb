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

    end # Attribute

  end # Mapper
end # ROM
