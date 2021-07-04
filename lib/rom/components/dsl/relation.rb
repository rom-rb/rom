# frozen_string_literal: true

require_relative "core"

require "rom/relation"

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

            schema(dsl.relation, gateway: dsl.gateway) if components.schemas.empty?
          end

          components.add(
            :relations, id: relation, constant: constant, gateway: gateway, provider: self
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
          configuration.config.gateways[gateway].adapter
        end
      end
    end
  end
end
