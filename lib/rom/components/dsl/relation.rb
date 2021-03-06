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

        option :id, type: Types::Strict::Symbol

        option :dataset, default: -> { id }

        option :gateway, default: -> { :default }

        settings(component: [:id, :dataset, :gateway])

        # @api private
        def call
          # TODO: deprecate `schema(:foo, as: :bar)` syntax because it's confusing as it actually
          # configures relation, not schema, to use a specific dataset (:foo) and a custom id (:bar)
          # This is why we have this awkward `schema.dataset` here
          add(dataset: schema.dataset, constant: constant, provider: constant)
        end

        # @api private
        memoize def constant
          build_class do |dsl|
            class_exec(&dsl.block) if dsl.block
            schema(dsl.dataset, as: dsl.id) if components.schemas.empty?
          end
        end

        # @api private
        def class_name
          class_name_inferrer[
            id,
            type: :relation,
            inflector: inflector,
            **config.components
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
          config.gateways[gateway].adapter if config.gateways.key?(gateway)
        end
      end
    end
  end
end
