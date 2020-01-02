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
      #   @return [Hash<Symbol, Hash>] A hash with attribute names as
      #   keys and attribute representations as values.
      #
      #   @see [Schema.build_attribute_info]
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
      ruby2_keywords(:initialize) if respond_to?(:ruby2_keywords, true)

      # Defines a relation attribute with its type and options.
      #
      # When only options are given, type is left as nil. It makes
      # sense when it is used alongside an schema inferrer, which will
      # populate the type.
      #
      # @see Relation.schema
      #
      # @api public
      def attribute(name, type_or_options, options = EMPTY_HASH)
        if attributes.key?(name)
          ::Kernel.raise ::ROM::AttributeAlreadyDefinedError,
                         "Attribute #{name.inspect} already defined"
        end

        attributes[name] = build_attribute_info(name, type_or_options, options)
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

      # Builds a representation of the information needed to create an
      # attribute. It returns a hash with `:type` and `:options` keys.
      #
      # @return [Hash]
      #
      # @see [Schema.build_attribute_info]
      #
      # @api private
      def build_attribute_info(name, type_or_options, options = EMPTY_HASH)
        type, options = if type_or_options.is_a?(::Hash)
                          [nil, type_or_options]
                        else
                          [build_type(type_or_options, options), options]
                        end
        Schema.build_attribute_info(
          type, **options, name: name
        )
      end

      # Builds a type instance from base type and meta options
      #
      # @return [Dry::Types::Type] Type instance
      #
      # @api private
      def build_type(type, options = EMPTY_HASH)
        if options[:read]
          type.meta(source: relation, read: options[:read])
        elsif type.optional? && type.meta[:read]
          type.meta(source: relation, read: type.meta[:read].optional)
        else
          type.meta(source: relation)
        end.meta(Attribute::META_OPTIONS.map { |opt| [opt, options[opt]] if options.key?(opt) }.compact.to_h)
      end

      # Specify which key(s) should be the primary key
      #
      # @api public
      def primary_key(*names)
        names.each do |name|
          attributes[name][:type] =
            attributes[name][:type].meta(primary_key: true)
        end
        self
      end

      # Enables for the schema
      #
      # @param [Symbol] plugin_name Plugin name
      # @param [Hash] options Plugin options
      #
      # @api public
      def use(plugin_name, options = ::ROM::EMPTY_HASH)
        plugin = ::ROM.plugin_registry[:schema].fetch(plugin_name, adapter)
        app_plugin(plugin, options)
      end

      # @api private
      def app_plugin(plugin, options = ::ROM::EMPTY_HASH)
        plugin.extend_dsl(self)
        @plugins[plugin.name] = [plugin, plugin.config.to_hash.merge(options)]
      end

      # @api private
      def call(&block)
        instance_exec(&block) if block
        instance_exec(&definition) if definition

        schema_class.define(relation, **opts) do |schema|
          plugins.values.each do |plugin, options|
            plugin.apply_to(schema, **options)
          end
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
