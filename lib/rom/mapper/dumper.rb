module ROM
  class Mapper

    class Dumper
      include Concord.new(:header, :model, :object), Adamantium

      def call
        header.each_with_object([]) { |attribute, tuple|
          tuple << object.send(attribute.name)
        }
      end

    end # Dumper

  end # Mapper
end # ROM
