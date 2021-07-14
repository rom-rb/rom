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

        settings(id: :dataset)

        # @api private
        def call
          add(constant: constant, config: {adapter: adapter})
        end

        # @api private
        memoize def constant
          build_class do |dsl|
            class_exec(&dsl.block) if dsl.block
          end
        end

        # @api private
        def id
          config[:id]
        end

        # @api private
        def adapter
          config.fetch(:adapter) { provider.config.gateways[config[:gateway]].adapter }
        end

        # @api private
        def class_name
          class_name_inferrer[
            id,
            type: :relation,
            inflector: inflector,
            class_namespace: provider.config.class_namespace
          ]
        end

        # @api private
        def class_parent
          ROM::Relation[adapter]
        end
      end
    end
  end
end
