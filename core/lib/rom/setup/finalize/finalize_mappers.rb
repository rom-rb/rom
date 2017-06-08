require 'rom/registry'

module ROM
  class Finalize
    class FinalizeMappers
      attr_reader :mapper_classes, :mapper_objects, :registry_hash

      # @api private
      def initialize(mapper_classes, mapper_objects)
        @mapper_classes = mapper_classes
        @mapper_objects = mapper_objects

        @registry_hash = [@mapper_classes.map(&:base_relation) + @mapper_objects.keys].
                           flatten.
                           uniq.
                           each_with_object({}) { |n, h| h[n] = {} }
      end

      # @api private
      def run!
        mappers = registry_hash.each_with_object({}) do |(relation_name, relation_mappers), h|
          relation_mappers.update(build_mappers(relation_name))

          if mapper_objects.key?(relation_name)
            relation_mappers.update(mapper_objects[relation_name])
          end

          h[relation_name] = MapperRegistry.new(relation_mappers)
        end

        Registry.new(mappers)
      end

      private

      def build_mappers(relation_name)
        mapper_classes.
          select { |klass| klass.base_relation == relation_name }.
          each_with_object({}) { |klass, h| h[klass.register_as || klass.relation] = klass.build  }
      end
    end
  end
end
