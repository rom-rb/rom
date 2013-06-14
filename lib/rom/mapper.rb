module ROM

  class Mapper
    include Concord.new(:header, :model)

    def load(tuple)
      loader(tuple).object
    end

    def dump(object)
      dumper(object).tuple
    end

    def loader(tuple)
      Loader.new(header, model, tuple)
    end

    def dumper(object)
      Dumper.new(header, model, object)
    end

  end # Mapper

end # ROM
