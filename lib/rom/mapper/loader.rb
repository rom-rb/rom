module ROM
  class Mapper

    class Loader
      include Concord.new(:header, :model, :tuple), Adamantium

      Result = Struct.new(:object, :identity) { include Adamantium }

      def call
        Result.new(object, identity)
      end

      private

      def object
        header.each_with_object(model.allocate) { |attribute, object|
          object.send("#{attribute.name}=", tuple[attribute.tuple_key])
        }
      end

      def identity
        header.keys.map { |key| tuple[key.tuple_key] }
      end

    end # AttributeSet

  end # Mapper
end # ROM
