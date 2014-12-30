require 'rom/mapper_builder'

module ROM
  class Setup
    class MapperDSL
      attr_reader :mappers

      def initialize(&block)
        @mappers = []
        instance_exec(&block)
      end

      def define(name, options = {}, &block)
        mappers << [name, options, block]
        self
      end
    end
  end
end
