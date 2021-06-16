# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Command < Core
      id :command

      # @!attribute [r] relation_name
      #   @return [Symbol] The relation identifier
      #   @api public
      option :relation_name, type: Types.Instance(Symbol), default: -> {
        # TODO: another workaround for auto_register specs not using actual rom classes
        constant.respond_to?(:relation) ? constant.relation : constant.name.to_sym
      }

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
