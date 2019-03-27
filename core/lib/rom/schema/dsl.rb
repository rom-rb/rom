# frozen_string_literal: true

require 'dry/equalizer'

require 'rom/types'
require 'rom/attribute'
require 'rom/schema/associations_dsl'

module ROM
  class Schema
    # Schema DSL exposed as `schema { .. }` in relation classes
    #
    # @api public
    class DSL < BasicObject
      KERNEL_METHODS = %i(extend method).freeze
      KERNEL_METHODS.each { |m| define_method(m, ::Kernel.instance_method(m)) }

      extend Initializer

      # @!attribute [r] relation
      #   @return [Relation::Name] The name of the schema's relation
      param :relation

      # @!attribute [r] inferrer
      #   @return [Inferrer] Optional attribute inferrer
      option :inferrer, default: -> { DEFAULT_INFERRER }

      # @!attribute [r] schema_class
      #   @return [Class] Schema class that should be instantiated
      option :schema_class, default: -> { Schema }

      # @!attribute [r] attr_class
      #   @return [Class] Attribute class that should be used
      option :attr_class, default: -> { Attribute }

      # @!attribute [r] adapter
      #   @return [Symbol] The adapter identifier used in gateways
      option :adapter, default: -> { :default }

      # @!attribute [r] attributes
      #   @return [Hash] A hash with attributes defined by the DSL
      attr_reader :attributes

      # @!attribute [r] plugins
      #   @return [Hash] A hash with schema plugins enabled in a schema
      attr_reader :plugins

      # @!attribute [r] definition
      #   @return [Proc] Definition block passed to DSL
      attr_reader :definition

      # @!attribute [r] associations_dsl
      #   @return [AssociationDSL] Associations defined within a block
      attr_reader :associations_dsl

      # @api private
      def initialize(*, &block)
        super

        @attributes = {}
        @plugins = {}

        @definition = block
      end

      # Defines a relation attribute with its type
      #
      # @see Relation.schema
      #
      # @api public
      def attribute(name, type, options = EMPTY_HASH)
        if attributes.key?(name)
          ::Kernel.raise ::ROM::AttributeAlreadyDefinedError,
                         "Attribute #{ name.inspect } already defined"
        end

        attributes[name] = build_type(name, type, options)
      end

      # Define associations for a relation
      #
      # @example
      #   class Users < ROM::Relation[:sql]
      #     schema(infer: true) do
      #       associations do
      #         has_many :tasks
      #         has_many :posts
      #         has_many :posts, as: :priority_posts, view: :prioritized
      #         belongs_to :account
      #       end
      #     end
      #   end
      #
      #   class Posts < ROM::Relation[:sql]
      #     schema(infer: true) do
      #       associations do
      #         belongs_to :users, as: :author
      #       end
      #     end
      #
      #     view(:prioritized) do
      #       where { priority <= 3 }
      #     end
      #   end
      #
      # @return [AssociationDSL]
      #
      # @api public
      def associations(&block)
        @associations_dsl = AssociationsDSL.new(relation, &block)
      end

      # Builds a type instance from a name, options and a base type
      #
      # @return [Dry::Types::Type] Type instance
      #
      # @api private
      def build_type(name, type, options = EMPTY_HASH)
        if options[:read]
          type.meta(name: name, source: relation, read: options[:read])
        elsif type.optional? && !type.meta[:read] && type.right.meta[:read]
          type.meta(name: name, source: relation, read: type.right.meta[:read].optional)
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

      private

      # Return schema opts
      #
      # @return [Hash]
      #
      # @api private
      def opts
        opts = { attributes: attributes.values, inferrer: inferrer, attr_class: attr_class }

        if associations_dsl
          { **opts, associations: associations_dsl.call }
        else
          opts
        end
      end
    end
  end
end
