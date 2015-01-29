module ROM
  class Setup
    class MapperDSL
      attr_reader :mappers

      def initialize(&block)
        instance_exec(&block)
      end

      def define(name, options = {}, &block)
        Mapper.build_class(name, options, &block)
        self
      end
    end
  end
end
