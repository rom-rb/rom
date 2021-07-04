# frozen_string_literal: true

require "rom/relation/name"

require_relative "core"

module ROM
  module Components
    # @api public
    class Schema < Core
      id :schema

      # @!attribute [r] as
      #   @return [Symbol] Alias that should be used as the relation name
      option :as, optional: true, type: Types::Strict::Symbol

      # @!attribute [r] view
      #   @return [Symbol]
      option :view, type: Types::Strict::Bool, default: -> { false }

      # @!attribute [r] gateway
      #   @return [Symbol] Gateway identifier
      option :gateway, inferrable: true, type: Types::Strict::Symbol

      # @!attribute [r] adapter
      #   @return [Symbol] Adapter identifier
      option :adapter, inferrable: true, type: Types::Strict::Symbol

      # @!attribute [r] infer
      #   @return [Boolean] Whether the inferrer should be enabled or not
      option :infer, type: Types::Strict::Bool, default: -> { false }

      # @!attribute [r] block
      #   @return [Class] A proc for evaluation via schema DSL
      option :block, type: Types.Interface(:call)

      # @api public
      def namespace
        "schemas"
      end

      # @api private
      def canonical_schema
        id = components.schemas(provider: provider).first.id
        configuration.schemas[id]
      end

      # @api public
      def build
        if view?
          canonical_schema.instance_eval(&block)
        else
          schema = dsl.()

          schema.finalize_attributes!(gateway: _gateway, relations: relations)
          schema.finalize!
        end
      end

      # @api private
      memoize def name
        ROM::Relation::Name[as || id, id]
      end

      # @api private
      def dsl(**opts)
        provider.schema_dsl.new(**dsl_options, **opts)
      end

      # @api private
      def view?
        view.equal?(true)
      end

      # @api private
      def _gateway
        super if gateway?
      end

      private

      # @api private
      def dsl_options
        {relation: name,
         definition: block,
         plugins: plugins,
         inflector: inflector,
         adapter: provider.adapter,
         schema_class: provider.schema_class,
         attr_class: provider.schema_attr_class,
         inferrer: inferrer}
      end

      # @api private
      def inferrer
        provider.schema_inferrer.with(enabled: infer)
      end
    end
  end
end
