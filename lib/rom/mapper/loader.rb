module ROM
  class Mapper

    class Loader
      include Concord.new(:header, :model), Adamantium

      def call(tuple)
        header.each_with_object(model.allocate) { |attribute, object|
          object.instance_variable_set("@#{attribute.name}", tuple[attribute.tuple_key])
        }
      end

      def identity(tuple)
        header.keys.map { |key| tuple[key.tuple_key] }
      end

    end # AttributeSet

  end # Mapper
end # ROM
