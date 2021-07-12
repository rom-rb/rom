# frozen_string_literal: true

require "rom/support/inflector"

require "rom/initializer"
require "rom/types"
require "rom/attribute"
require "rom/schema/associations_dsl"

module ROM
  class Schema
    # Schema DSL exposed as `schema { .. }` in relation classes
    #
    # @api public
    class DSL
      extend Initializer

      # @!attribute [r] relation
      #   @return [Relation::Name] The name of the schema's relation
      option :relation

      # @!attribute [r] adapter
      #   @return [Symbol] The adapter identifier used in gateways
      option :adapter

      # @!attribute [r] inferrer
      #   @return [Inferrer] Optional attribute inferrer
      option :inferrer, default: -> { DEFAULT_INFERRER }

      # @!attribute [r] inflector
      #   @return [Dry::Inflector] String inflector
      #   @api private
      option :inflector, default: -> { Inflector }

      # @!attribute [r] schema_class
      #   @return [Class] Schema class that should be instantiated
      option :constant, default: -> { Schema }
      alias_method :schema_class, :constant

      # @!attribute [r] attr_class
      #   @return [Class] Attribute class that should be used
      option :attr_class, default: -> { Attribute }

      # @!attribute [r] plugins
      #   @return [Class] Plugins enabled by default through configuration
      option :plugins, default: -> { EMPTY_HASH.dup }

      # @!attribute [r] attributes
      #   @return [Hash<Symbol, Hash>] A hash with attribute names as
      #   keys and attribute representations as values.
      #
      #   @see [Schema.build_attribute_info]
      option :attributes, default: -> { EMPTY_HASH.dup }

      # @!attribute [r] definition
      #   @return [Class] An optional block that will be evaluated as part of this DSL
      option :definition, type: Types.Instance(Proc), default: -> { Proc.new {} }

      # @api private
      def self.new(**options, &block)
        if block
          super(definition: block, **options)
        else
          super
        end
      end

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
          raise(
            ::ROM::AttributeAlreadyDefinedError,
            "Attribute #{name.inspect} already defined"
          )
        end

        attributes[name] = build_attribute_info(name, type_or_options, options)
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
        @associations_dsl = AssociationsDSL.new(relation, inflector, &block)
      end

      # Enable a plugin in the schema DSL
      #
      # @param [Symbol] plugin_name Plugin name
      # @param [Hash] options Plugin options
      #
      # @api public
      def use(plugin_name, **options)
        apply_plugin(::ROM.plugin_registry[:schema].fetch(plugin_name, adapter), **options)
      end

      # @api private
      def call
        plugins.each do |plugin|
          apply_plugin(plugin)
        end

        instance_eval(&definition) if definition

        schema_class.define(relation, **opts) do |schema|
          applied_plugins.each do |(plugin, options)|
            plugin.apply_to(schema, **options)
          end
        end
      end

      private

      # @api private
      def apply_plugin(plugin, **options)
        plugin.extend_dsl(self)
        applied_plugins << [plugin, plugin.config.to_h.merge(options)]
      end

      # @api private
      def plugin_options(name)
        applied_plugins.detect { |(plugin, options)| options if plugin.name == name }.last
      end

      # @api private
      def applied_plugins
        @applied_plugins ||= []
      end

      # Return schema opts
      #
      # @return [Hash]
      #
      # @api private
      def opts
        opts = {
          attributes: attributes.values,
          inferrer: inferrer,
          attr_class: attr_class,
          inflector: inflector
        }

        if @associations_dsl
          {**opts, associations: @associations_dsl.call}
        else
          opts
        end
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
        end.meta(Attribute::META_OPTIONS.map { |opt|
                   [opt, options[opt]] if options.key?(opt)
                 } .compact.to_h)
      end
    end
  end
end
