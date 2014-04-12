# encoding: utf-8

require 'rom/mapper/builder/definition'
require 'rom/mapper'

module ROM
  class Relation

    # Builder DSL for ROM mappers
    #
    class MapperBuilder
      include Concord.new(:schema)

      attr_reader :definitions, :mappers

      # @api public
      def self.call(*args, &block)
        new(*args).call(&block)
      end

      # @api private
      def initialize(*args)
        super
        @definitions = {}
        @mappers = {}
      end

      # @api public
      def call(&block)
        instance_eval(&block)
      end

      # @api public
      def relation(name, mapper = nil, &block)
        if block_given?
          @definitions[name] = Mapper::Builder::Definition.new(&block)
        else
          mappers[name] = mapper
        end

        self
      end

      # @api private
      def finalize
        definitions.each do |name, definition|
          header = schema[name].header

          attributes = definition.attributes.map do |args|
            build_attribute_options(header, *args)
          end

          mappers[name] = definition.mapper || Mapper.build(attributes, definition.options)
        end

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

      private

      # @api private
      def build_attribute_options(header, name, options = {})
        header_name = options.fetch(:from, name)
        keys = header.keys.flat_map { |key_header| key_header.flat_map(&:name) }

        defaults = {
          key: keys.include?(header_name),
          type: header[header_name].type.primitive
        }

        [name, defaults.merge(options)]
      end

    end # MapperBuilder
  end # Relation
end # ROM
