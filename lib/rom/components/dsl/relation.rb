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

        # @api private
        def call
          super(constant: constant, config: constant.config.component)
        end

        # @api private
        memoize def constant
          build_class do |dsl|
            config.component.adapter = dsl.adapter if dsl.adapter
            class_exec(&dsl.block) if dsl.block

            if (schema_dataset = components.schemas.first&.config&.dataset)
              config.component.dataset = schema_dataset
            end
          end
        end

        # @api private
        memoize def class_name
          class_name_inferrer[
            config.id,
            type: :relation,
            inflector: inflector,
            class_namespace: provider.class_namespace
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
