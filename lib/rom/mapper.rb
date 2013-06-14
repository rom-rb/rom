module ROM

  class Mapper
    include Concord.new(:header, :model)

    def load(tuple)
      loader(tuple).call
    end

    def dump(object)
      header.each_with_object([]) { |attribute, tuple|
        tuple << object.send(attribute.name)
      }
    end

    private

    def loader(tuple)
      Loader.new(header, model, tuple)
    end

  end # Mapper

end # ROM
