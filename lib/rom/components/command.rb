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
      def build(**opts)
        relation = registry.relations[relation_id]

        trigger(
          "commands.class.before_build",
          command: constant,
          gateway: registry.gateways[relation.gateway],
          dataset: relation.dataset,
          relation: relation,
          adapter: adapter
        )

        command = constant.build(relation)

        if (mappers = opts[:map_with])
          command >> mappers.map { |mapper| relation.mappers[mapper] }.reduce(:>>)
        else
          command
        end
      end

      # @api private
      def relation_id
        config[:relation_id]
      end

      # @api private
      def adapter
        config[:adapter]
      end
    end
  end
end
