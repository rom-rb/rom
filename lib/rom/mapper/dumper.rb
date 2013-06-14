module ROM
  class Mapper

    class Dumper
      include Concord.new(:header, :model, :object), Adamantium::Flat

      def tuple
        header.each_with_object([]) { |attribute, tuple|
          tuple << object.send(attribute.name)
        }
      end
      memoize :tuple, :freezer => :noop

      def identity
        header.keys.map { |key| object.send("#{key.name}") }
      end
      memoize :identity, :freezer => :noop

    end # Dumper

  end # Mapper
end # ROM
