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

        # @api private
        def call
          constant = build_class do |dsl|
            class_exec(&dsl.block) if dsl.block
            if components.schemas.empty?
              schema(dsl.relation, gateway: dsl.gateway)
            end
          end

          components.add(
            :relations,
            id: relation, constant: constant, gateway: gateway, provider: self
          )
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
        def infer_option(option, component:)
          case option
          when :id then relation
          when :adapter then adapter
          when :gateway then gateway
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
