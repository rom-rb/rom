# encoding: utf-8

module ROM

  class Mapper

    def self.build(registry, mapping)
      new(Builder.call(registry, mapping))
    end

    attr_reader :loader
    attr_reader :dumper

    alias_method :transformer, :loader

    def initialize(transformer)
      @loader = transformer
      @dumper = transformer.inverse
    end

    def load(tuple)
      loader.run(tuple)
    end

    def dump(object)
      dumper.run(object)
    end
  end # class Mapper
end # module ROM
