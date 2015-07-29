require 'rom/repository/header_builder'

module ROM
  class Repository < Gateway
    class MapperBuilder
      attr_reader :header_builder

      attr_reader :registry

      def self.registry
        @__registry__ ||= {}
      end

      def self.new(header_builder = HeaderBuilder.new)
        super
      end

      def initialize(header_builder)
        @header_builder = header_builder
        @registry = self.class.registry
      end

      def call(ast)
        registry[ast.hash] ||= Mapper.build(header_builder[ast])
      end
      alias_method :[], :call
    end
  end
end
