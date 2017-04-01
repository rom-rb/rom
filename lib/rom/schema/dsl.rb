require 'dry-equalizer'
require 'rom/types'

module ROM
  # Relation schema
  #
  # @api public
  class Schema
    AttributeAlreadyDefinedError = Class.new(StandardError)

    include Dry::Equalizer(:name, :attributes)
    include Enumerable

    attr_reader :name, :attributes, :inferrer

    # @api public
    class DSL < BasicObject
      define_method(:extend, ::Kernel.instance_method(:extend))

      attr_reader :relation, :attributes, :inferrer, :schema_class, :plugins, :adapter

      # @api private
      def initialize(relation, schema_class: Schema, inferrer: Schema::DEFAULT_INFERRER, adapter: :default, &block)
        @relation = relation
        @inferrer = inferrer
        @schema_class = schema_class
        @attributes = {}
        @plugins = {}
        @adapter = adapter

        instance_exec(&block) if block
      end

      # Defines a relation attribute with its type
      #
      # @see Relation.schema
      #
      # @api public
      def attribute(name, type, options = EMPTY_HASH)
        if attributes.key?(name)
          ::Kernel.raise ::ROM::Schema::AttributeAlreadyDefinedError,
                         "Attribute #{ name.inspect } already defined"
        end

        attributes[name] = build_type(name, type, options)
      end

      # Builds a type instance from a name, options and a base type
      #
      # @return [Dry::Types::Type] Type instance
      #
      # @api private
      def build_type(name, type, options = EMPTY_HASH)
        if options[:read]
          type.meta(name: name, source: relation, read: options[:read])
        else
          type.meta(name: name, source: relation)
        end
      end

      # Specify which key(s) should be the primary key
      #
      # @api public
      def primary_key(*names)
        names.each do |name|
          attributes[name] = attributes[name].meta(primary_key: true)
        end
        self
      end

      # Enables for the schema
      #
      # @param [Symbol] plugin Plugin name
      # @param [Hash] options Plugin options
      #
      # @api public
      def use(plugin, options = ::ROM::EMPTY_HASH)
        mod = ::ROM.plugin_registry.schemas.adapter(adapter).fetch(plugin)
        mod.extend_dsl(self)
        @plugins[plugin] = [mod, options]
      end

      # @api private
      def call
        schema_class.define(relation, attributes: attributes.values, inferrer: inferrer) do |schema|
          plugins.values.each { |(plugin, options)|
            plugin.apply_to(schema, options)
          }
        end
      end
    end
  end
end
