module ROM
  class Mapper

    class Dumper
      include Concord::Public.new(:header, :model), Adamantium

      def call(object)
        header.each_with_object([]) { |attribute, tuple|
          tuple << object.send(attribute.name)
        }
      end

      def identity(object)
        header.keys.map { |key| object.send("#{key.name}") }
      end

      def new_object(*args, &block)
        model.new(*args, &block)
      end

    end # Dumper

  end # Mapper
end # ROM
