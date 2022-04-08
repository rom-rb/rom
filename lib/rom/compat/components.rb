# frozen_string_literal: true

require "rom/components/core"
require "rom/components/relation"
require "rom/components/command"

module ROM
  class Components::Core
    # @api private
    def trigger(event, payload)
      registry.trigger("configuration.#{event}", payload)
    end

    # @api private
    def notifications
      registry.notifications
    end
  end

  class Components::Relation < Components::Core
    mod = Module.new do
      def build
        relation = super

        trigger("relations.class.ready", relation: constant, adapter: adapter)

        trigger(
          "relations.schema.set",
          schema: relation.schema,
          adapter: adapter,
          gateway: config[:gateway],
          relation: constant,
          registry: registry
        )

        trigger("relations.object.registered", registry: registry, relation: relation)

        relation
      end
    end

    prepend(mod)
  end

  class Components::Command < Components::Core
    mod = Module.new do
      def build
        relation = registry.relations[config.relation]

        trigger(
          "commands.class.before_build",
          command: constant,
          gateway: registry.gateways[relation.gateway],
          dataset: relation.dataset,
          relation: relation,
          adapter: adapter
        )

        super
      end
    end

    prepend(mod)
  end
end
