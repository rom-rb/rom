require 'rom/repository/header_builder'

module ROM
  class Repository
    class MapperBuilder
      attr_reader :header_builder

      attr_reader :registry

      def self.new(header_builder = HeaderBuilder.new)
        super
      end

      def initialize(header_builder)
        @header_builder = header_builder
        @registry = {}
      end

      def call(relation)
        registry[relation] ||= Mapper.build(header_builder[relation])
      end
      alias_method :[], :call
    end
  end
end
