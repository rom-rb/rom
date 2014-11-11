require 'rom/reader_registry/mapper_builder'

module ROM
  class ReaderRegistry < Registry

    class DSL
      attr_reader :relations, :mappers, :readers

      def initialize(relations)
        @relations = relations
        @mappers = {}
        @readers = ReaderRegistry.new
      end

      def call
        readers
      end

      def define(name, options = {}, &block)
        parent = options.fetch(:parent) { relations[name] }

        builder = MapperBuilder.new(name, parent, mappers, options)
        builder.instance_exec(&block)
        builder.call

        readers[name] = Reader.new(name, parent, mappers) unless options[:parent]

        self
      end

      def respond_to_missing?(name, include_private = false)
        relations.key?(name)
      end

      private

      def method_missing(name)
        relations[name]
      end

    end

  end
end
