# encoding: utf-8

module ROM
  class Mapper

    # Builder DSL for ROM mappers
    #
    class Builder
      attr_reader :schema, :mappers

      # @api public
      def self.call(*args, &block)
        new(*args).call(&block)
      end

      # Initialize a new mapping instance
      #
      # @return [undefined]
      #
      # @api private
      def initialize(schema)
        @schema = schema
        @mappers = {}
      end

      # @api public
      def relation(name, &block)
        definition = Definition.build(schema[name].header, &block)
        mappers[name] = definition.mapper
        self
      end

      # @api private
      def call(&block)
        instance_eval(&block)
      end

      # @api private
      def finalize
        mappers.freeze
      end

      # @api private
      def each(&block)
        mappers.each(&block)
      end

      # @api private
      def [](name)
        mappers.fetch(name)
      end

    end # Builder

  end # Mapper
end # ROM
