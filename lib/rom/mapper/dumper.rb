module ROM
  class Mapper

    class Dumper
      include Concord.new(:header, :model, :object), Adamantium

      Result = Struct.new(:tuple, :identity) { include Adamantium }

      def call
        Result.new(tuple, identity)
      end

      private

      def tuple
        header.each_with_object([]) { |attribute, tuple|
          tuple << object.send(attribute.name)
        }
      end

      def identity
        header.keys.map { |key| object.send("#{key.name}") }
      end

    end # Dumper

  end # Mapper
end # ROM
