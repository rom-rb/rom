# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Command < Core
      # @!attribute [r] relation_id
      #   @return [Symbol]
      option :relation_id, type: Types::Strict::Symbol, inferrable: true

      # @!attribute [r] constant
      #   @return [Class] Component's target class
      option :constant, type: Types.Interface(:new)

      # @api public
      def build(**opts)
        relation = relations[relation_id]

        trigger(
          "commands.class.before_build",
          command: constant,
          gateway: gateways[relation.gateway],
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
    end
  end
end
