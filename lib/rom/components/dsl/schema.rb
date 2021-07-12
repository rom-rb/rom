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

        settings(:as, :adapter, provider: [:id, {id: :dataset, as: :id}])

        # @api private
        def call
          # TODO: move this to rom/compat
          provider.config.component.update(config[:provider]) unless _config[:view]
          add
        end
      end
    end
  end
end
