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

        settings(:as, :adapter)

        # @api private
        def call
          add
        end
      end
    end
  end
end
