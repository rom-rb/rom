require 'rom/mapper_registry/mapper_builder'

module ROM
  class MapperRegistry

    class DSL
      attr_reader :relations, :mappers

      def initialize(relations)
        @relations = relations
        @mappers = {}
      end

      def call
        MapperRegistry.new(mappers)
      end

      private

      def method_missing(name, &block)
        if relations.key?(name)
          @builder = MapperBuilder.new(name, relations[name])
          instance_exec(&block)
        else
          @builder.instance_exec(&block)
          (@mappers[@builder.name] ||= MapperRegistry.new)[name] = @builder.call
        end
      end

    end

  end
end
