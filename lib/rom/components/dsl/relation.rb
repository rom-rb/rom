# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # Setup DSL-specific relation extensions
      #
      # @private
      class Relation < Core
        key :relations

        option :relation

        option :dataset, default: -> { relation }

        settings(component: [:dataset, :gateway, relation: :id])

        # @api private
        def call
          # TODO: deprecate `schema(:foo, as: :bar)` syntax because it's confusing as it actually
          # configures relation, not schema, to use a specific dataset (:foo) and a custom id (:bar)
          # This is why we have this awkward `schema.dataset` here
          add(id: relation, dataset: schema.dataset, constant: constant)
        end

        # @api private
        memoize def constant
          build_class do |dsl|
            class_exec(&dsl.block) if dsl.block
            schema(dsl.dataset, as: dsl.relation, gateway: dsl.gateway) if components.schemas.empty?
          end
        end

        # @api private
        def class_name
          class_name_inferrer[
            relation,
            type: :relation,
            inflector: inflector,
            **provider_config.components
          ]
        end

        # @api private
        def class_parent
          ROM::Relation[adapter]
        end

        # @api private
        def schema
          constant.components.schemas.first
        end

        # @api private
        def adapter
          provider_config.gateways[gateway].adapter if provider_config.gateways.key?(gateway)
        end
      end
    end
  end
end
