require 'rom/mapper_registry/mapper_builder'

module ROM
  class MapperRegistry

    class DSL
      attr_reader :relations, :mappers

      def initialize(relations)
        @relations = relations
        @mappers = {}
      end

      def relation(name, &block)
        builder = MapperBuilder.new(relations[name])
        builder.instance_exec(&block)
        @mappers[name] = builder.call
      end

      def call
        MapperRegistry.new(@mappers)
      end

    end

  end
end
