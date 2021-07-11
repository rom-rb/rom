# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # Setup DSL-specific relation extensions
      #
      # @private
      class Schema < Core
        key :schemas

        option :id

        option :as, default: -> { id }

        option :view, default: -> { false }

        option :infer, default: -> { false }

        option :gateway, default: -> { resolve_gateway }

        settings(component: {id: :dataset, as: :id})

        # @api private
        def call
          owner.config.update(resolve_config) unless view
          add(provider: owner)
        end

        private

        # @api private
        def resolve_gateway
          config.component.gateway
        end
      end
    end
  end
end
