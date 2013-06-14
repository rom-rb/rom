module ROM
  class Mapper

    class Loader
      include Concord.new(:header, :model, :tuple), Adamantium

      def call
        header.each_with_object(model.allocate) { |attribute, object|
          object.send("#{attribute.name}=", tuple[attribute.tuple_key])
        }
      end

    end # AttributeSet

  end # Mapper
end # ROM
