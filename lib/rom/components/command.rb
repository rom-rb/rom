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
        relation = resolver.relations[config.relation]

        trigger(
          "commands.class.before_build",
          command: constant,
          gateway: resolver.gateways[relation.gateway],
          dataset: relation.dataset,
          relation: relation,
          adapter: adapter
        )

        constant.build(relation)
      end

      # @api public
      def namespace
        "#{super}.#{config.relation}"
      end

      # @api private
      def adapter
        config.adapter
      end
    end
  end
end
