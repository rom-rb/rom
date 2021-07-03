# frozen_string_literal: true

require "rom/relation/name"
require_relative "core"

module ROM
  module Components
    # @api public
    class Schema < Core
      id :schema

      # @!attribute [r] id
      #   @return [Symbol] Registry local id
      option :id, type: Types::Strict::Symbol

      # @!attribute [r] view
      #   @return [Symbol]
      option :view, type: Types::Strict::Bool.default(false)

      # @!attribute [r] name
      #   @return [Symbol] Relation name
      option :name, type: Types.Instance(ROM::Relation::Name)

      # @!attribute [r] gateway_name
      #   @return [Symbol] Gateway identifier
      option :gateway_name, optional: true, type: Types::Strict::Symbol

      # @!attribute [r] adapter
      #   @return [Symbol] Adapter identifier
      option :adapter, optional: true, type: Types::Strict::Symbol

      # @!attribute [r] infer
      #   @return [Boolean] A proc for evaluation via schema DSL
      option :infer, optional: true, type: Types::Strict::Bool.default(false)

      # @!attribute [r] block
      #   @return [Class] A proc for evaluation via schema DSL
      option :block, type: Types.Interface(:call)

      # @!attribute [r] dsl_class
      #   @return [Class] The DSL class
      option :dsl_class, optional: true

      # @!attribute [r] attr_class
      #   @return [Class] Schema's DSL attribute class
      option :attr_class, optional: true

      # @!attribute [r] relation_class
      #   @return [Class]
      option :relation_class, type: Types.Instance(Class)

      # @!attribute [r] inferrer
      #   @return [Inferrer] Schema's inferrer
      option :inferrer, optional: true, reader: false

      # @api public
      def namespace
        "schemas"
      end

      # @api private
      def canonical_schema
        id = components.schemas(relation_class: relation_class).first.id
        configuration.schemas[id]
      end

      # @api public
      def build
        if view?
          canonical_schema.instance_eval(&block)
        else
          plugins = self.plugins

          schema = dsl.call(inflector: inflector) do
            plugins.each { |plugin| app_plugin(plugin) }
          end

          schema.finalize_attributes!(gateway: gateway, relations: relations)
          schema.finalize!
        end
      end

      # @api private
      def gateway
        gateways[gateway_name] if gateways.key?(gateway_name)
      end

      # @api private
      def dsl(**opts)
        dsl_class.new(name, **dsl_options, **opts, &block)
      end

      # @api private
      def view?
        view.equal?(true)
      end

      private

      # @api private
      def dsl_options
        {schema_class: constant, attr_class: attr_class, inferrer: inferrer}
      end

      # @api private
      def inferrer
        options[:inferrer].with(enabled: infer)
      end
    end
  end
end
