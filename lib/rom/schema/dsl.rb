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
      KERNEL_METHODS = %i(extend method).freeze
      KERNEL_METHODS.each { |m| define_method(m, ::Kernel.instance_method(m)) }

      attr_reader :relation, :attributes, :inferrer, :schema_class, :plugins, :adapter, :definition

      # @api private
      def initialize(relation, schema_class: Schema, inferrer: Schema::DEFAULT_INFERRER, adapter: :default, &block)
        @relation = relation
        @inferrer = inferrer
        @schema_class = schema_class
        @attributes = {}
        @plugins = {}
        @adapter = adapter

        @definition = block
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
        app_plugin(mod, options)
      end

      # @api private
      def app_plugin(plugin, options = ::ROM::EMPTY_HASH)
        plugin_name = ::ROM.plugin_registry.schemas.adapter(adapter).plugin_name(plugin)
        plugin.extend_dsl(self)
        @plugins[plugin_name] = [plugin, plugin.config.to_hash.merge(options)]
      end

      # @api private
      def call(&block)
        instance_exec(&block) if block
        instance_exec(&definition) if definition

        schema_class.define(relation, opts) do |schema|
          plugins.values.each { |(plugin, options)|
            plugin.apply_to(schema, options)
          }
        end
      end

      # @api private
      def plugin_options(plugin)
        @plugins[plugin][1]
      end

      # @api private
      def opts
        { attributes: attributes.values, attr_class: ::ROM::Schema::Attribute, inferrer: inferrer }
      end
    end
  end
end
