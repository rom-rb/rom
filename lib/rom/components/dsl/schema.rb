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

        INVALID_IDS = %i[relations schema].freeze

        option :id

        option :as, default: -> { id }

        option :view, default: -> { false }

        option :infer, default: -> { false }

        option :gateway, default: -> { resolve_gateway }

        # @api private
        def call
          if options[:view]
            add
          else
            component = replace

            raise MissingSchemaClassError, provider unless component.constant

            # TODO: this can go away by simply skipping readers in case of clashes
            raise InvalidRelationName, id if INVALID_IDS.include?(component.id)

            provider_config.component.id = component.relation_id
            provider_config.component.dataset = component.dataset

            # TODO: this should go away
            if components.datasets(id: component.dataset).empty?
              provider.dataset(component.dataset, gateway: component.gateway)
            end

            component
          end
        end

        private

        # @api private
        def resolve_gateway
          if provider_config.component.respond_to?(:gateway)
            provider_config.component.gateway
          else
            :default
          end
        end
      end
    end
  end
end
