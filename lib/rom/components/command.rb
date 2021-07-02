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
        options[:id] || constant.register_as || constant.default_name
      end

      # Registry namespace
      #
      # @return [String]
      #
      # @api public
      def namespace
        "commands.#{relation_id}"
      end

      # @return [Symbol]
      #
      # @api public
      def relation_id
        constant.relation
      end

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
