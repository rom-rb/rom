module ROM

  class Mapper
    include Concord.new(:loader, :dumper)

    def load(tuple)
      loader.call(tuple)
    end

    def dump(object)
      dumper.call(object)
    end

  end # Mapper

end # ROM
