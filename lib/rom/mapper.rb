module ROM

  class Mapper
    include Concord.new(:header, :model)

    def load(tuple)
      header.each_with_object(model.allocate) { |(attribute, name), object|
        object.send("#{name}=", tuple[attribute.name])
      }
    end

    def dump(object)
      header.each_with_object([]) { |(_, name), tuple|
        tuple << object.send(name)
      }
    end

  end # Mapper

end # ROM
