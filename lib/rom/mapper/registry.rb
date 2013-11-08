# encoding: utf-8

module ROM
  class Mapper

    class Registry
      include Concord.new(:entries)

      def self.build(mappings)
        new(mappings.each_with_object({}) { |(model, mapping), registry|
          registry[model] = Mapper.build(registry, mapping)
        })
      end

      def [](model)
        entries.fetch(model)
      end
    end # class Registry
  end # class Mapper
end # module ROM
