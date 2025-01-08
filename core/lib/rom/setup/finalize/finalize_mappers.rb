# frozen_string_literal: true

require 'rom/registry'

module ROM
  class Finalize
    class FinalizeMappers
      attr_reader :mapper_classes
      attr_reader :mapper_objects
      attr_reader :registry_hash

      # @api private
      def initialize(mapper_classes, mapper_objects)
        @mapper_classes = mapper_classes
        @mapper_objects = mapper_objects

        check_duplicate_registered_mappers

        @registry_hash = [@mapper_classes.map(&:base_relation) + @mapper_objects.keys]
          .flatten
          .uniq
          .to_h { [_1, {}] }
      end

      # @api private
      def run!
        cache = Cache.new

        mappers = registry_hash.to_h do |relation_name, relation_mappers|
          relation_mappers.update(build_mappers(relation_name))

          if mapper_objects.key?(relation_name)
            relation_mappers.update(mapper_objects[relation_name])
          end

          [relation_name, MapperRegistry.new(relation_mappers, cache: cache)]
        end

        Registry.new(mappers, cache: cache)
      end

      private

      def check_duplicate_registered_mappers
        duplicates = mapper_classes.map { [_1.relation, _1.register_as] }.tally.select { _2 > 1 }

        case duplicates.first
        in [rel, as], _
          raise MapperAlreadyDefinedError,
                "Mapper with `register_as #{as.inspect}` registered more " \
                "than once for relation #{rel.inspect}"
        else
          nil
        end
      end

      def build_mappers(relation_name)
        mapper_classes
          .select { |klass| klass.base_relation == relation_name }
          .to_h { |k| [k.register_as || k.relation, k.build] }
      end
    end
  end
end
