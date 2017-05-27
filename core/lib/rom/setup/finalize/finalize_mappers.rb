require 'rom/registry'

module ROM
  class Finalize
    class FinalizeMappers
      # @api private
      def initialize(mapper_classes, mapper_objects)
        @mapper_classes = mapper_classes
        @mapper_objects = mapper_objects
      end

      # @api private
      def run!
        registry = @mapper_classes.each_with_object({}) do |klass, h|
          name = klass.register_as || klass.relation
          (h[klass.base_relation] ||= {})[name] = klass.build
        end

        registry_hash = registry.each_with_object({}).each { |(relation, mappers), h|
          h[relation] = MapperRegistry.new(mappers)
        }

        @mapper_objects.each do |relation, mappers|
          if registry_hash.key?(relation)
            mappers_registry = registry_hash[relation]
            mappers.each { |name, mapper| mappers_registry[name] = mapper }
          else
            registry_hash[relation] = MapperRegistry.new(mappers)
          end
        end

        Registry.new(registry_hash)
      end
    end
  end
end
