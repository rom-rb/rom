# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # Setup DSL-specific relation extensions
      #
      # @private
      class Relation < Core
        option :relation

        option :dataset, default: -> { relation }

        config(component: [:dataset, :gateway, relation: :id])

        # @api private
        def call
          # TODO: deprecate `schema(:foo, as: :bar)` syntax because it's confusing as it actually
          # configures relation, not schema, to use a specific dataset (:foo) and a custom id (:bar)
          # This is why we have this awkward `schema.dataset` here
          components.add(
            :relations,
            id: relation,
            dataset: schema.dataset,
            gateway: gateway,
            constant: constant,
            provider: self
          )
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
          class_name_inferrer[relation, type: :relation, inflector: inflector, **config.components]
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
        def infer_option(option, component:)
          case option
          when :adapter then adapter
          end
        end

        # @api private
        def adapter
          config.gateways[gateway].adapter if config.gateways.key?(gateway)
        end
      end
    end
  end
end
