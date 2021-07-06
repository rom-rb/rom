# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # Setup DSL-specific relation extensions
      #
      # @private
      class Schema < Core
        INVALID_IDS = %i[relations schema].freeze

        option :id

        option :view

        option :relation

        # @api private
        def call(**options)
          if view
            components.add(
              :schemas, id: id || view, view: true, provider: provider, **options, block: block
            )
          else
            component = components.replace(
              :schemas, id: id, provider: provider, **options, block: block
            )

            raise MissingSchemaClassError, provider unless provider.schema_class

            # TODO: this can go away by simply skipping readers in case of clashes
            raise InvalidRelationName, id if INVALID_IDS.include?(component.id)

            # TODO: this should go away
            if components.datasets(id: component.name.dataset).empty?
              provider.dataset(component.name.dataset, gateway: component.gateway)
            end
          end
        end
      end
    end
  end
end
