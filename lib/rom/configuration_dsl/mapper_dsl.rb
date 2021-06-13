# frozen_string_literal: true

require "rom/mapper/builder"

module ROM
  module ConfigurationDSL
    # Mapper definition DSL used by Setup DSL
    #
    # @private
    class MapperDSL
      attr_reader :configuration

      # @api private
      def initialize(configuration, &block)
        @configuration = configuration
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
      def define(name, options = EMPTY_HASH, &block)
        constant = Mapper::Builder.build_class(
          name, configuration.components.mappers, options, &block
        )

        configuration.components.add(
          :mappers, key: constant.register_as, base_relation: constant.base_relation, constant: constant
        )

        self
      end

      # TODO
      #
      # @api public
      def register(relation, mappers)
        mappers.each do |name, mapper|
          configuration.components.add(:mappers, key: name, base_relation: relation, object: mapper)
        end
      end
    end
  end
end
