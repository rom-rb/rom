module ROM

  class Mapper
    include Concord.new(:header, :model)

    def load(tuple)
      loader(tuple).call
    end

    def dump(object)
      dumper(object).call
    end

    def loader(tuple)
      Loader.new(header, model, tuple)
    end

    def dumper(object)
      Dumper.new(header, model, object)
    end

  end # Mapper

end # ROM
