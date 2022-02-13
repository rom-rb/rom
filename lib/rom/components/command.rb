# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Command < Core
      # @!attribute [r] constant
      #   @return [Class] Component's target class
      option :constant, type: Types.Interface(:new)

      # @api public
      def build
        gateway.command(constant, relation: registry.relations[config.relation])
      end

      # @api private
      def adapter
        config.adapter
      end
    end
  end
end
