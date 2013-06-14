module ROM
  class Mapper

    class Loader
      include Concord.new(:header, :model, :tuple), Adamantium::Flat

      def object
        header.each_with_object(model.allocate) { |attribute, object|
          object.send("#{attribute.name}=", tuple[attribute.tuple_key])
        }
      end
      memoize :object, :freezer => :noop

      def identity
        header.keys.map { |key| tuple[key.tuple_key] }
      end
      memoize :identity, :freezer => :noop

    end # AttributeSet

  end # Mapper
end # ROM
