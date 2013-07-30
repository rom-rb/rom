module ROM

  class Mapper
    include Concord::Public.new(:header, :loader, :dumper)

    DEFAULT_LOADER = Loader::Allocator
    DEFAULT_DUMPER = Dumper

    def self.build(header, model, options = {})
      loader_class = options.fetch(:loader_class) { DEFAULT_LOADER }
      dumper_class = options.fetch(:dumper_class) { DEFAULT_DUMPER }

      loader = loader_class.new(header, model)
      dumper = dumper_class.new(header, model)

      new(header, loader, dumper)
    end

    def call(relation)
      relation.rename(header.mapping)
    end

    # @api public
    def identity(object)
      dumper.identity(object)
    end

    # @api public
    def identity_from_tuple(tuple)
      loader.identity(tuple)
    end

    # @api public
    def new_object(*args, &block)
      dumper.new_object(*args, &block)
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
