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
    # @see Components::DSL::Schema
    #
    # @deprecated
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
      option :plugins, default: -> { EMPTY_ARRAY.dup }

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
      # sense when it is used alongside a schema inferrer, which will
      # populate the type.
      #
      # @see Relation.schema
      #
      # @api public
      def attribute(name, type_or_options, options = EMPTY_HASH)
        if attributes.include?(name)
          raise(
            ::ROM::AttributeAlreadyDefinedError,
            "Attribute #{name.inspect} already defined"
          )
        end

        build_attribute_info(name, type_or_options, options).tap do |attr_info|
          attributes[name] = attr_info
        end
      end

      # Specify which key(s) should be the primary key
      #
      # @api public
      def primary_key(*names)
        names.each do |name|
          attributes[name][:type] = attributes[name][:type].meta(primary_key: true)
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
        if block
          __assoc_dsl__.instance_eval(&block)
        else
          __assoc_dsl__.registry.values
        end
      end

      # @api private
      def __assoc_dsl__
        @__assoc_dsl__ ||= AssociationsDSL.new(relation, inflector)
      end

      # Enable a plugin in the schema DSL
      #
      # @param [Symbol] name Plugin name
      # @param [Hash] options Plugin options
      #
      # @api public
      def use(name, **options)
        plugin = ::ROM.plugin_registry[:schema].fetch(name, adapter).configure do |config|
          config.update(options)
        end
        plugins << plugin.enable(self)
        self
      end

      # @api public
      def plugin(name, **options)
        plugin = plugins.detect { |plugin| plugin.name == name }
        plugin.config.update(options) unless options.empty?
        plugin
      end

      # @api private
      def call
        schema_class.define(relation, **config)
      end

      # @api private
      def config
        @config ||=
          begin
            # Enable available plugin's
            plugins.each do |plugin|
              plugin.enable(self) unless plugin.enabled?
            end

            # Apply custom definition block if it exists
            instance_eval(&definition) if definition

            # Apply plugin defaults
            plugins.each do |plugin|
              plugin.apply_to(self)
            end

            attributes.freeze
            associations.freeze

            opts.freeze
          end
      end

      # @api public
      def inspect
        %(<##{self.class} relation=#{relation} attributes=#{attributes} plugins=#{plugins}>)
      end

      private

      # Return schema opts
      #
      # @return [Hash]
      #
      # @api private
      def opts
        {attributes: attributes.values,
         associations: associations,
         attr_class: attr_class,
         plugins: plugins}
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
        meta = Attribute::META_OPTIONS
          .map { |opt| [opt, options[opt]] if options.key?(opt) }
          .compact
          .to_h

        base =
          if options[:read]
            type.meta(source: relation, read: options[:read])
          elsif type.optional? && type.meta[:read]
            type.meta(source: relation, read: type.meta[:read].optional)
          else
            type.meta(source: relation)
          end

        if meta.empty?
          base
        else
          base.meta(meta)
        end
      end
    end
  end
end
