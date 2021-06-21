# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Command < Core
      id :command

      # Registry id
      #
      # @return [Symbol]
      #
      # @api public
      def id
        constant.register_as || constant.default_name
      end

      # @return [Symbol]
      #
      # @api public
      def relation_id
        constant.relation
      end

      # @api public
      def build(relation:)
        trigger(
          "commands.class.before_build",
          command: constant,
          gateway: gateways[relation.gateway],
          dataset: relation.dataset,
          adapter: adapter
        )

        constant.extend_for_relation(relation) if constant.restrictable

        constant.build(relation)
      end
    end
  end
end
