require 'rom/mapping/mapper_builder'

module ROM
  class Mapping

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
        Mapping.new(@mappers)
      end

    end

  end
end
