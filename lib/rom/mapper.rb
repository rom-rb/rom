module ROM

  class Mapper
    include Concord::Public.new(:loader, :dumper)

    # @api public
    def identity(object)
      dumper.identity(object)
    end

    # @api public
    def load(tuple)
      loader.call(tuple)
    end

    # @api public
    def dump(object)
      dumper.call(object)
    end

  end # Mapper

end # ROM
