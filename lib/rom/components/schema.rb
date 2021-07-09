# frozen_string_literal: true

require "rom/relation/name"

require_relative "core"

module ROM
  module Components
    # @api public
    class Schema < Core
      id :schema

      # @!attribute [r] constant
      #   @return [Class] Component's target class
      option :constant, type: Types.Interface(:new), inferrable: true

      # @!attribute [r] as
      #   @return [Symbol] Alias that should be used as the relation name
      option :as, type: Types::Strict::Symbol, optional: true

      # @!attribute [r] view
      #   @return [Symbol]
      option :view, type: Types::Strict::Bool, default: -> { false }

      # @!attribute [r] gateway
      #   @return [Symbol] Gateway identifier
      option :gateway, type: Types::Strict::Symbol, inferrable: true

      # @!attribute [r] adapter
      #   @return [Symbol] Adapter identifier
      option :adapter, type: Types::Strict::Symbol, inferrable: true

      # @!attribute [r] block
      #   @return [Class] A proc for evaluation via schema DSL
      option :block, type: Types.Interface(:call)

      # @!attribute [r] attr_class
      #   @return [Class]
      option :attr_class, type: Types.Instance(Class), inferrable: true

      # @!attribute [r] dsl_class
      #   @return [Class]
      option :dsl_class, type: Types.Interface(:new), inferrable: true

      # @!attribute [r] infer
      #   @return [Boolean] Whether the inferrer should be enabled or not
      option :infer, type: Types::Strict::Bool, default: -> { false }

      # @!attribute [r] inferrer
      #   @return [#with]
      option :inferrer, type: Types.Interface(:with), inferrable: true

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
      def relation_id
        as || id
      end

      # @api private
      def name
        ROM::Relation::Name[relation_id, dataset]
      end
      alias_method :dataset, :id

      # @api private
      def dsl(**opts)
        dsl_class.new(**dsl_options, **opts)
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
        {relation: name, # TODO: Schema#name could now probably just be a symbol id
         schema_class: constant,
         attr_class: attr_class,
         adapter: adapter, # TODO: decouple Schema::DSL from adapter
         definition: block,
         plugins: plugins,
         inflector: inflector,
         inferrer: inferrer.with(enabled: infer)}
      end
    end
  end
end
