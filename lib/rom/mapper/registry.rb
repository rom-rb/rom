# encoding: utf-8

module ROM
  class Mapper

    class Registry
      include Concord.new(:entries)

      UNKNOWN_MAPPER_MSG = 'No registered mapper for: %s'

      def self.build(mappings)
        new(mappings.each_with_object({}) { |(model, mapping), registry|
          registry[model] = Mapper.build(registry, mapping)
        })
      end

      def [](model)
        entries.fetch(model) do
          fail UnknownMapper, UNKNOWN_MAPPER_MSG % model.inspect
        end
      end
    end # Registry
  end # Mapper
end # ROM
