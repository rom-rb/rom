require 'rom/configuration_dsl/mapper'

module ROM
  module ConfigurationDSL
    # Mapper definition DSL used by Setup DSL
    #
    # @private
    class MapperDSL
      attr_reader :registry, :mapper_classes, :mapper_classes

      # @api private
      def initialize(registry, mapper_classes, block)
        @registry = registry
        @mapper_classes = mapper_classes
        @defined_mappers = []

        instance_exec(&block)

        @mapper_classes = @defined_mappers
      end

      # Define a mapper class
      #
      # @param [Symbol] name of the mapper
      # @param [Hash] options
      #
      # @return [Class]
      #
      # @api public
      def define(name, options = EMPTY_HASH, &block)
        @defined_mappers << Mapper.build_class(name, (@mapper_classes + @defined_mappers), options, &block)
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
