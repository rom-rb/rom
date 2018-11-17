require 'rom/mapper/builder'

module ROM
  class Mapper
    # Mapper definition DSL used by Setup DSL
    #
    # @private
    class MapperDSL
      attr_reader :configuration, :mapper_classes, :defined_mappers

      # @api private
      def initialize(configuration, mapper_classes, block)
        @configuration = configuration
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
        @defined_mappers << Builder.build_class(name, (@mapper_classes + @defined_mappers), options, &block)
        self
      end

      # TODO
      #
      # @api public
      def register(relation, mappers)
        configuration.register_mapper(relation => mappers)
      end
    end
  end
end
