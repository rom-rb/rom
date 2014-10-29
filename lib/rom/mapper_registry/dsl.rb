require 'rom/mapper_registry/mapper_builder'

module ROM
  class MapperRegistry

    class DSL
      attr_reader :relations, :mappers, :readers

      def initialize(relations)
        @relations = relations
        @mappers = {}
        @readers = {}
      end

      def call
        @readers
      end

      def model(*args)
        @builder.model(*args)

        name = @builder.name

        mappers[name] = @builder.call

        @readers[name] = Reader.new(name, @root, mappers)
      end

      private

      def method_missing(name, &block)
        if relations.key?(name)
          @root = relations[name]
          @builder = MapperBuilder.new(name, @root.header)
          instance_exec(&block)
        else
          @builder = MapperBuilder.new(name, @root.header, @mappers[@root.name])
          @builder.instance_exec(&block)
          mappers[name] = @builder.call
        end
      end

    end

  end
end
