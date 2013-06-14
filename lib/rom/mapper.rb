module ROM

  class Mapper
    include Concord.new(:header, :model)

    def load(tuple)
      header.each_with_object(model.allocate) { |attribute, object|
        object.send("#{attribute.name}=", tuple[attribute.field])
      }
    end

    def dump(object)
      header.each_with_object([]) { |attribute, tuple|
        tuple << object.send(attribute.name)
      }
    end

  end # Mapper

end # ROM
