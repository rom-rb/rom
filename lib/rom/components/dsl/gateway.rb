# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # @private
      class Gateway < Core
        key :gateways

        # @api private
        def call
          add
        end
      end
    end
  end
end
