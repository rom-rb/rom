require 'rom/setup_dsl/mapper'

module ROM
  class Setup
    # Mapper definition DSL used by Setup DSL
    #
    # @private
    class MapperDSL
      attr_reader :registry

      # @api private
      def initialize(registry, &block)
        @registry = registry
        instance_exec(&block)
      end

      # Define a mapper class
      #
      # @param [Symbol] name of the mapper
      # @param [Hash] options
      #
      # @return [Class]
      #
      # @api public
      def define(name, options = {}, &block)
        Mapper.build_class(name, options, &block)
        self
      end

      # TODO
      #
      # @api public
      def register(relation, mappers)
        registry.register_mapper(relation => mappers)
      end
    end
  end
end
